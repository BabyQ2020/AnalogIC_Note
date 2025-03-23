# 配置文件
**好记性不如烂笔头**

 [TOC]

## 1 .bashrc
to be continued

## 2 .cdsinit
### 2.1 基础必备配置
```
; ##open LibManger when start CIW ##
ddsOpenLibManager()

;## set font size ##
hiSetFont("label" ?size 14)
hiSetFont("ciw" ?size 14)
hiSetFont("text" ?size 14)

; ## set default simulator ##
envSetVal("asimenv.startup" "simulator" 'string "spectre")

; ## simulation result path ##
envSetVal("asimenv.startup" "projectDir" 'string "<path>")
```

### 2.2 仿真结果显示设置
```
;##  set the style of waves ##
envSetVal("viva.trace" "lineStyle" 'string "solid")
envSetVal("viva.trace" "lineThickness" 'string "thick")
envSetVal("asimenv.plotting" "useDisplayDrf" 'boolean nil )
```
也可以通过加载文件来设置仿真结果，在.cdsinit文件中添加下面内容
```
load("<path>/trace_set.txt")
```
trace_set.txt 可以同时设置schematic中，高亮信号线显示的颜色以及类型，以及仿真波形的显示类型， 文件内容如下：
```
drSetPacket( "display" "y0" "blank" "solid" "winColor5" 	"winColor5"		"outline")
drSetPacket( "display" "y1" "blank" "solid" "brown"     	"brown"         	"outline")
drSetPacket( "display" "y2" "blank" "solid" "red"			"red"           	"outline")
drSetPacket( "display" "y3" "blank" "solid" "pink"      	"pink"          	"outline")
drSetPacket( "display" "y4" "blank" "solid" "orange"    	"orange"        	"outline")
drSetPacket( "display" "y5" "blank" "solid" "green"     	"green"         	"outline")
drSetPacket( "display" "y6" "blank" "solid" "blue"      	"blue"          	"outline")
drSetPacket( "display" "y7" "blank" "solid" "purple"    	"purple"        	"outline")
drSetPacket( "display" "y8" "blank" "solid" "gold"      	"gold"          	"outline")
drSetPacket( "display" "y9" "blank" "solid" "silver"    	"silver"        	"outline")
```

### 2.3 加载设置文件
```
; ####load bindkey.il####
load(“xxxx/bindkeys.il")

; ## load waves setting file ##
load("<path>/trace_set.txt")
```

### 2.4 其他配置
```
; ## set same color with schematic and waves ##
envSetVal("asimenv.plotting" "UseDisplayDrf" 'boolean t)
 
; ## setting the result'name when start run ##
envSetVal("adexl.historyNamePrefix" "showNameHistoryForm" 'boolean t)
```

### 2.5 集成其他软件
```
;## integrate calibre##
skillPath=getSkillPath();
setSkillPath(append(skillPath list("/opt/Mentor/Calibre2018/aoi_cal_2018.4_34.26/lib")));
load("calibre.skl");
```

## 3 .cdsenv
to be continued...




