---
layout: default
title: SparkSQL
tags:
- Computer Science
---


## Summary of the paper

 Provides a Dataframe API which integrates both procedural and declarative api.
 To take advantage of the above integration an extensible query optimizer (catalyst)
 is described. 

## Key points

1. The key insight of the paper seems to be that while applications exist which provide 
declarative api (hive,pig) there was'nt a framework which allowed both procedural and 
declarative. The sheer ton of features the paper talks about seems like a gigantic engineering 
effort by data bricks. 
2. Dataframe API is introduced on top of Collection<RDD> with a matching uniform schema. (kind of like a table.)
3. Using this representation of data, scala is used to represent all SQL like operations. 
4. Provides a lot of features (user defined data types, external data sources, schema inference for JSON,
Integration with ML pipelines)
5. [**Main**]Catalyst optimizer:Provides an effecient query plan by going through 
        
        a. Anaysis: performs schema anlysis, and resolves same columns
        b. optimizer: performs standard optimizations, such as constant folding
            key insight of the paper is that adding new optimizations is easy.
        c. Physical planning: Uses a cost optimizer. 
        d. Actual code generation 
        e. **Uses a ton of features from functional languages (scala) to make optimizer extensible**
6. Evaluation: 
    
    Sql vs Sql: Compared with a purely sql engines and found to be competitive. credits scala based code generator
    
    Sql+procedural vs SparkSql: almost 2x performance due to pipelining between both the phases. 
  
    Programmer usability: Since sql is being provided as an abstraction, life is simpler without the need 
    to explicity wrap sql as map-reduce.
    
## extensions

Is it possible that in a pipelined architecture, that 
bottle necks can be created dynamically. if a query is running over an hour. Could it not have
multiple bottle necks at different phases of exuection. if so could we use a dynamic optimizer

## Final notes

A very enjoyable paper. 
