# mips_processor

simple mips processor with 5 stage pipelines



## 数据冒险相关

* BNE、BEQ、JR前如果出现write-use相关，则需要在前面插一个延迟槽（nop）