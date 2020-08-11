---
layout: default
title: Single Node GPUs
tags:
- Computer Science
---

My obsession with trying to build a kernel ,
led me to stumble on bad coding practices which cripple at scale.

[Ref. book Computer Systems - A Programmers Perspective]

1.  Using function to check end of loop

```  
    while(i<check_condition()){
    //do something
    }   
```

It is expected that the compiler optimizes by running the check_condition()
only once.Storing it at some temporary location . But a look at the
assembly code .Shows repeated calls to the check_condition

    ```.L6:
    	subl	$1, -4(%rbp)
    .L5:
    	movl	-4(%rbp), %eax
    	movl	%eax, %edi
    	call	check
    	testb	%al, %al
    	jne	.L6
    	leave
    	```


2.  A similar reason can be found while referencing arrays in loops.

    ```
    while(){
        a[0]++;
    }
    ```

    should be written as .


        ```
        while(){
            temp++
        }
        a[0]=temp
        ```        
    This would decrease atleast 4 assembly instructions .
