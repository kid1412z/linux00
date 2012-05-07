linux00
=======

简单的多任务内核程序, 参考: 《Linux 内核完全剖析》 赵炯

系统环境：Ubuntu Linux 12.04LTS
Linux version 3.2.0-24-generic-pae (buildd@vernadsky) 
(gcc version 4.6.3 (Ubuntu/Linaro 4.6.3-1ubuntu5) ) #37-Ubuntu SMP 
 Wed Apr 25 10:47:59 UTC 2012

boot.s -- 对原有的引导代码用AT&T汇编语法进行了重写
head.s -- 简单的多任务内核程序
Makefile  编译脚本：
          输入：make命令，生成启动软盘镜像Image（位置放在用户主目录下）
虚拟机工具bochs的配置文件（位置在用户主目录下）

