#!/usr/bin/env python
"""
Author: David Wolinsky
Version: 0.01

A file system that interacts with an xmlrpc HT.
"""

from collections import defaultdict
from errno import ENOENT
from stat import S_IFDIR, S_IFLNK, S_IFREG
from sys import argv, exit
from time import time

from fuse import FUSE, FuseOSError, Operations, LoggingMixIn
from xmlrpclib import Binary
import sys, pickle, xmlrpclib, logging
from threading import Timer
import os, threading
class HtProxy:
  """ Wrapper functions so the FS doesn't need to worry about HT primitives."""
  # A hashtable supporting atomic operations, i.e., retrieval and setting
  # must be done in different operations
  def __init__(self, url0, numOfServers):
    self.rpc1 = []
    self.rpc2 = []
    self.rpc3 = []
   #print url0
    self.url = url0
    self.url1 = 'http://localhost:7000'
    self.url2 = 'http://localhost:9000'
   # print self.url
   # print self.url1
   # print self.url2
    self.numservers = numOfServers
    self.create_servers1(self.url,numOfServers)
    self.create_servers2(self.url1,numOfServers)
    self.create_servers3(self.url2,numOfServers)
    self.refresh()
   
#initializing an array of servers
  def refresh(self):
    threading.Timer(60, self.checkdata).start()
       

  def checkdata(self):
    keyset = set()  
    urlarr = []
    urlarr.append(self.url)
    urlarr.append(self.url1)
    urlarr.append(self.url2)
    tick = 0
    #print urlarr
    for u in urlarr:
      for i in range(self.numservers):
        try:
 	  s = xmlrpclib.ServerProxy(u[0:len(u)-1]+str(i))
          temp = s.return_content()
          keyset = (keyset | set(temp.keys()))
        except Exception, err:
	  tick +=1
    for tempkey in keyset:
      rcv = self.get(tempkey) 
   
    threading.Timer(60, self.checkdata).start()
    
 # def check_coherence(self, y)
  def create_servers1(self, url, numOfServers):
    self.rpc1 = []
    for i in range(numOfServers):
      serverDict = {}
      serverDict["server"]= xmlrpclib.Server(url[0:len(url)-1]+str(i))
      self.rpc1.append(serverDict)
      serverDict = {}
#    print "rp-------------------------------------------------------------------------------------------------------"
 #   print self.rpc

  def create_servers2(self, url, numOfServers):
    self.rpc2 = []
    for i in range(numOfServers):
      serverDict = {}
      serverDict["server"]= xmlrpclib.Server(url[0:len(url)-1]+str(i))
      self.rpc2.append(serverDict)
      serverDict = {}
  # Retrieves a value from the SimpleHT, returns KeyError, like dictionary, if
  def create_servers3(self, url, numOfServers):
    self.rpc3 = []
    for i in range(numOfServers):
      serverDict = {}
      serverDict["server"]= xmlrpclib.Server(url[0:len(url)-1]+str(i))
      self.rpc3.append(serverDict)
      serverDict = {}
  # there is no entry in the SimpleHT
  def __getitem__(self, key):
    rv = self.get(key)
    if rv == None:
      raise KeyError()
    return pickle.loads(rv)
    
  # Stores a value in the SimpleHT
  def __setitem__(self, key, value):
    self.put(key, pickle.dumps(value))

  # Sets the TTL for a key in the SimpleHT to 0, effectively deleting it
  def __delitem__(self, key):
    self.put(key, "", 0)
      
  # Retrieves a value from the DHT, if the results is non-null return true,
  # otherwise false
  def __contains__(self, key):
    return self.get(key) != None

  def get(self, key):
    servers = self.alloc_server(key)
   # print "------------------------------------------in SimpleHt's get function-------------------------------"
   # print servers
    res = [] # store the values in a temp variable
    tick = 0
    for server in servers:
      try:
        x = server.get(Binary(key))
        res.append(x)
      except Exception, err:
        tick+=1
    if tick>1:
      raise err
   # print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ resssssssssssssssssssssss~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
   # print res
    #compare the output values here
    if tick<1:
      if (res[0] == res[1]):
        if(res[2]!=res[0]) and ("value" in res[0]):
          temp = res[0]["value"].data
    #      print "--------------------------------------------value in res ---------------------------------"
     #     print temp
          self.put(key,temp,10000)
        if "value" in res[0]:
          return res[0]["value"].data
        else: 
          return None
      elif(res[1] == res[2]):
        if(res[0] != res[1]) and ("value" in res[1]):
          temp = res[1]["value"].data
          self.put(key, temp,10000)
        if "value" in res[1]:
          return res[1]["value"].data
        else:
          return None
      elif(res[2] == res[0]):
        if(res[1]!= res[2]) and ("value" in res[2]):
          temp = res[2]["value"].data
      #    print "--------------------------------------------------------value in res corrupt-----------------------------"
      #    print temp
          self.put(key, temp,10000)
    
        if "value" in res[2]:
          return res[2]["value"].data
        else:
          return None
      else:
       # print "----------------------------all 3 copies corrupt-----------------"
        return None
    elif tick==1: 
      if (res[0] == res[1]):
        if "value" in res[0]:
          return res[0]["value"].data
        else:
          return None
     # if (res[1] == res[2]):
      #  if "value" in res[1]:
       #   return res[1]["value"].data
       # else:
       #   return None
     # if (res[0] == res[2]):
      #  if "value" in res[2]:
       #   return res[2]["value"].data
       # else:
        #  return None
    else: 
      return None
#    if "value" in res:
 #     return res["value"].data
  #  else:
   #   return None

  def put(self, key, val, ttl=10000):
    servers = []
    servers = self.alloc_server(key)
   # print "--------------------------------------------put()-----------------------------------------------------------------"
   # print servers
    s_write = 0
    tick1 = 0
    for server in servers:
      try:
        server.put(Binary(key), Binary(val), ttl)
      except Exception,err:
        s_write = s_write+1

    if (s_write < 1):
      return True
    else:
      return False

  def read_file(self, filename):
    servers=[]
    servers= self.alloc_server(filename)
    return server.read_file(Binary(filename))

  def write_file(self, filename):
    server = self.alloc_server(filename)
    return server.write_file(Binary(filename))

  def alloc_server(self,key):
    serverDictLen = 0
    flag = 0
    servers = []
    index = 0
    for i in self.rpc1:
     
      if key in i:
        servers.append(i["server"])
        servers.append(self.rpc2[index]["server"])
        servers.append(self.rpc3[index]["server"])
        flag = 0 # reset flag later when key found in some other loop
        break
      else:
         flag= 1
        # print "key not found, flag set"
      index = index+1

    if flag == 1:
      serverId = 0 
      for i in self.rpc1:
        serverDictLen += len(i)
      serverId = serverDictLen%len(self.rpc1)
     # print "the selected server's id is:"
     # print serverId
      servers.append(self.rpc1[serverId]["server"])
      servers.append(self.rpc2[serverId]["server"])
      servers.append(self.rpc3[serverId]["server"])
     # adding keys to the serverDict
    #  print "-----------------------------------------------------------before------------------------------"
     # print servers
      temp = {}
      temp = self.rpc1[serverId]
      temp[key] = key
      self.rpc1[serverId] = temp
     # self.rpc2[serverId] = temp
     # self.rpc3[serverId] = temp
      temp = {}   
      temp = self.rpc2[serverId]
      temp[key] = key
      self.rpc2[serverId] = temp
   
      temp = {}
      temp = self.rpc3[serverId]
      temp[key] = key
      self.rpc3[serverId] = temp
   # print "------------------------------------------alloc_server-----------------------------------------------------------------"
   # print self.rpc1 
   # print self.rpc2  
   # print self.rpc3  
   # print servers, "------------the server that has been returned"
    return servers

################################################################################

class Memory(LoggingMixIn, Operations):
  """Example memory filesystem. Supports only one level of files."""
  def __init__(self, ht):
    self.files = ht
   # print(type(self.files))
    self.fd = 0
    now = time()
    if '/' not in self.files:
      self.files['/'] = dict(st_mode=(S_IFDIR | 0755), st_ctime=now,
        st_mtime=now, st_atime=now, st_nlink=2, contents=['/'])

  def chmod(self, path, mode):
    ht = self.files[path]
    print(type(ht))
    ht['st_mode'] &= 077000
    ht['st_mode'] |= mode
    self.files[path] = ht
    return 0

  def chown(self, path, uid, gid):
    ht = self.files[path]
    if uid != -1:
      ht['st_uid'] = uid
    if gid != -1:
      ht['st_gid'] = gid
    self.files[path] = ht
  
  def create(self, path, mode):
    self.files[path] = dict(st_mode=(S_IFREG | mode), st_nlink=1, st_size=0,
        st_ctime=time(), st_mtime=time(), st_atime=time(), contents='')
   # print("type of self.files in create", type(self.files))

    ht = self.files['/']
    ht['st_nlink'] += 1
    ht['contents'].append(path)
    self.files['/'] = ht
   # print("type of ht", type(ht))
   # print("type of self.files", type(self.files))
    self.fd += 1
    return self.fd
  
  def getattr(self, path, fh=None):
    if path not in self.files['/']['contents']:
      raise FuseOSError(ENOENT)
   # print("type of self.files in getattr is", type(self.files))
    return self.files[path]
  
  def getxattr(self, path, name, position=0):
    attrs = self.files[path].get('attrs', {})
    try:
      return attrs[name]
    except KeyError:
      return ''    # Should return ENOATTR
  
  def listxattr(self, path):
    return self.files[path].get('attrs', {}).keys()
  
  def mkdir(self, path, mode):
    self.files[path] = dict(st_mode=(S_IFDIR | mode),
        st_nlink=2, st_size=0, st_ctime=time(), st_mtime=time(),
        st_atime=time(), contents=[])
    ht = self.files['/']
    ht['st_nlink'] += 1
    ht['contents'].append(path)
    self.files['/'] = ht

  def open(self, path, flags):
    self.fd += 1
    return self.fd
  
  def read(self, path, size, offset, fh):
    ht = self.files[path]
    if 'contents' in self.files[path]:
      return self.files[path]['contents'][offset:offset+size]
    return None
  
  def readdir(self, path, fh):
    return ['.', '..'] + [x[1:] for x in self.files['/']['contents'] if x != '/']
  
  def readlink(self, path):
    return self.files[path]['contents']
  
  def removexattr(self, path, name):
    ht = self.files[path]
    attrs = ht.get('attrs', {})
    if name in attrs:
      del attrs[name]
      ht['attrs'] = attrs
      self.files[path] = ht
    else:
      pass    # Should return ENOATTR
  
  def rename(self, old, new):
    f = self.files[old]
    self.files[new] = f
    del self.files[old]
    ht = self.files['/']
    ht['contents'].append(new)
    ht['contents'].remove(old)
    self.files['/'] = ht
  
  def rmdir(self, path):
    del self.files[path]
    ht = self.files['/']
    ht['st_nlink'] -= 1
    ht['contents'].remove(path)
    self.files['/'] = ht
  
  def setxattr(self, path, name, value, options, position=0):
    # Ignore options
    ht = self.files[path]
    attrs = ht.get('attrs', {})
    attrs[name] = value
    ht['attrs'] = attrs
    self.files[path] = ht
  
  def statfs(self, path):
    return dict(f_bsize=512, f_blocks=4096, f_bavail=2048)
  
  def symlink(self, target, source):
    self.files[target] = dict(st_mode=(S_IFLNK | 0777), st_nlink=1,
      st_size=len(source), contents=source)

    ht = self.files['/']
    ht['st_nlink'] += 1
    ht['contents'].append(target)
    self.files['/'] = ht
  
  def truncate(self, path, length, fh=None):
    ht = self.files[path]
    if 'contents' in ht:
      ht['contents'] = ht['contents'][:length]
    ht['st_size'] = length
    self.files[path] = ht
  
  def unlink(self, path):
    ht = self.files['/']
    ht['contents'].remove(path)
    self.files['/'] = ht
    del self.files[path]
  
  def utimens(self, path, times=None):
    now = time()
    ht = self.files[path]
    atime, mtime = times if times else (now, now)
    ht['st_atime'] = atime
    ht['st_mtime'] = mtime
    self.files[path] = ht
  
  def write(self, path, data, offset, fh):
    # Get file data
    ht = self.files[path]
    tmp_data = ht['contents']
    toffset = len(data) + offset
    if len(tmp_data) > toffset:
      # If this is an overwrite in the middle, handle correctly
      ht['contents'] = tmp_data[:offset] + data + tmp_data[toffset:]
    else:
      # This is just an append
      ht['contents'] = tmp_data[:offset] + data
    ht['st_size'] = len(ht['contents'])
    self.files[path] = ht
    return len(data)

if __name__ == "__main__":
  if len(argv) != 4:
    print 'usage: %s <mountpoint> <remote hashtable> <numOfServers>' % argv[0]
    exit(1)
  url = argv[2]
  numOfServers = int(argv[3])
  # Create a new HtProxy object using the URL specified at the command-line
  #logging.basicConfig()
  #logging.getLogger().setLevel(logging.DEBUG)
  fuse = FUSE(Memory(HtProxy(url,numOfServers)), argv[1], foreground=True)
