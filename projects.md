---
title: My Projects
layout: default
---
  
  1.  <b>Paxos </b>:
      In a universe where IOT devices represented by servers communicate with a backend cluster,
      all communication happens via RMI's . The backend cluster synchronizes itself by employing the Paxos
      algorithm. written in Python
      [Source Code](https://github.com/sandeep06011991/spring17-lab3-sandeep06011991)
        
  2. <b>Consistent Database in Cassandra</b>:
     A Java driver which ensures consistency across cassandra clusters . Server side consistency(Totally ordered 
     multicast algorithm) and Client Side consistency(Monotonic reads,writes, writes follow reads and reads follow writes 
     using Lamport clocks)
     [Source Code](https://github.com/sandeep06011991/consistency)
      
  3.  <b>Memory Allocator and Garbage collector</b>:
      Replaced the memory allocator and garbage collector(malloc) in C++ with a custom allocator.
      The garbage collector is conservative collector . Malloc was replaced and linux kernel was run to 
      prove correctness.
      [Source Code](https://github.com/sandeep06011991/conservative-gc-sandeep06011991)
  
  4.  <b>Memcached  </b>:
      A memcached like server was built in C++. LRU and MRU cache eviction algorithms where used.
      Fragmentation and cache miss statistics for these algorithms was collected.
      [Source Code](https://github.com/sandeep06011991/memcached-clone-the-a-team)
            
  5.  <b>A compiler in Ocaml for a functional language.</b>:
      This compiles to ARM assembly. The language supports functions as first class objects, closure and arrays.
      The programs go through various transformations such as A-Normalization, Closure Conversion,register allocation.
      (Note to self. It has been too long since I wrote this code. Need to go over it again.
      This can be a blog post revise how this works)
      [Source Code of the main Compiler Module](/compiler.ml)      
      
  6. <b>Synthesizer in Ocaml </b>:
     A program with wholes is fed in (sketch) along with a behaviour modeled as a spec and a synthesizer
     fills up the wholes based on the spec .
     The program is transformed into a series of Constraint Equations which are fed into a SAT solver and solved.
     [Source Code](/synth.ml)
      
  7. <b>TCP through UDP </b>:
     The properties given by TCP (corruption, packet loss, pipe lining) where built given an evil unreliable channel
     which uses UDP written in Java.
     [Source Code](https://github.com/sandeep06011991/networking)
     