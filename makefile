#此项目源文件后缀类型
PROJECTTYPE = .c

#您想要生成可执行文件的名字
BinName :=obj.out 


#获取当前makefile绝对路径
pes_parent_dir:=$(shell pwd)/$(lastword $(MAKEFILE_LIST))
pes_parent_dir:=$(shell dirname $(pes_parent_dir))

#获取目录下所有子目录
AllDirs := $(shell cd $(pes_parent_dir); ls -R | grep '^\./.*:$$' | awk '{gsub(":","");print}') .

#添加成为绝对路径
AllDirs := $(foreach n,$(AllDirs),$(subst .,$(pes_parent_dir),$(n)))

#获取所有 .c/.cpp文件路径
Sources := $(foreach n,$(AllDirs) , $(wildcard $(n)/*$(PROJECTTYPE)))

#处理得到*.o 后缀文件名
OBJS = $(patsubst %$(PROJECTTYPE),%.o, $(Sources))  

#同理得到 *.d文件名
Deps := $(patsubst %$(PROJECTTYPE),%.d, $(Sources))  

#需要用到的第三方静态库
StaticLib :=

#需要用到的第三方动态链接库
DynamicLib := 

#真实二进制文件输出路径
Bin :=$(pes_parent_dir)/$(BinName)

#C语言编译器
CC = gcc

#C++编译器
CXX = g++

#简化rm -f
RM = -rm -f

#C语言配置参数
CFLAGS = -g  -pedantic -std=c99 -Wall -o

#C++配置参数
CXXFLAGS = -g -Wall -std=c11 

#头文件搜索路径
INCLUDE_PATH = $(foreach n,$(AllDirs) , -I$(n))
LDFLAGS = 

#指定AllLibs为终极目标 即:最新的Bin 
AllLibs:$(Bin)

#声明这个标签 des 用于观察当前的路径是否正确
.PHONY:des
des:
	@echo OBJS =  $(OBJS)
	@echo cur_makefile_path = $(pes_parent_dir)
	@echo AllDirs = $(AllDirs)
	@echo Sources = $(Sources)
	@echo Deps = $(Deps)

#对应关系 在本makefile中以空格隔开的后缀为.c 都会为其生成一个新的.d文件
%.d : %.c  
	   @echo 'finding $< depending head file'
	   @$(CC) -MT"$(<:.c=.o) $@" -MM $(INCLUDE_PATH) $(CPPFLAGS) $< > $@

#对于include中的*.d文件，只要里面任意有一个文件被修改，那么就会触发此规则生成一个新的*.o文件
%.o: %.d
	@echo compile $(<:d=c)
	@$(CC) -c $(<:.d=.c) $(INCLUDE_PATH) $(CFLAGS) $@ 

sinclude $(Sources:.c=.d)

$(Bin) : $(OBJS)  
	@echo bulding....
	@$(CC) $(OBJS)  $(CFLAGS) $(Bin)
	@echo created file: $(BinName)	

.PHONY : clean  
clean:   
	    @echo '清理所有文件'
	    @$(RM) $(OBJS) $(Deps) $(Bin)

.PHONY : cleanO
cleanO:
	    @echo '清理Obj && Dep'
	    @$(RM) $(OBJS) $(Deps)
#main.out: $(OBJ)
#	cc -o main.out $(OBJ)

	
