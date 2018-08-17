
H
Command: %s
53*	vivadotcl2 
route_design2default:defaultZ4-113
š
@Attempting to get a license for feature '%s' and/or device '%s'
308*common2"
Implementation2default:default2
xc7a35t2default:defaultZ17-347
Š
0Got license for feature '%s' and/or device '%s'
310*common2"
Implementation2default:default2
xc7a35t2default:defaultZ17-349
x
%Your %s license expires in %s day(s)
86*common2"
Implementation2default:default2
292default:defaultZ17-86
g
,Running DRC as a precondition to command %s
22*	vivadotcl2 
route_design2default:defaultZ4-22
G
Running DRC with %s threads
24*drc2
22default:defaultZ23-27
M
DRC finished with %s
79*	vivadotcl2
0 Errors2default:defaultZ4-198
\
BPlease refer to the DRC report (report_drc) for more information.
80*	vivadotclZ4-199
M

Starting %s Task
103*constraints2
Routing2default:defaultZ18-103
p
BMultithreading enabled for route_design using a maximum of %s CPUs97*route2
22default:defaultZ35-254
K

Starting %s Task
103*constraints2
Route2default:defaultZ18-103
g

Phase %s%s
101*constraints2
1 2default:default2#
Build RT Design2default:defaultZ18-101
:
.Phase 1 Build RT Design | Checksum: 13a2f5423
*common
‡

%s
*constraints2p
\Time (s): cpu = 00:00:21 ; elapsed = 00:00:19 . Memory (MB): peak = 979.543 ; gain = 113.5202default:default
m

Phase %s%s
101*constraints2
2 2default:default2)
Router Initialization2default:defaultZ18-101
r
\No timing constraints were detected. The router will operate in resource-optimization mode.
64*routeZ35-64
?
3Phase 2 Router Initialization | Checksum: be8aa64a
*common
‡

%s
*constraints2p
\Time (s): cpu = 00:00:21 ; elapsed = 00:00:19 . Memory (MB): peak = 985.461 ; gain = 119.4382default:default
g

Phase %s%s
101*constraints2
3 2default:default2#
Initial Routing2default:defaultZ18-101
9
-Phase 3 Initial Routing | Checksum: 36dc9319
*common
‡

%s
*constraints2p
\Time (s): cpu = 00:00:21 ; elapsed = 00:00:19 . Memory (MB): peak = 985.461 ; gain = 119.4382default:default
j

Phase %s%s
101*constraints2
4 2default:default2&
Rip-up And Reroute2default:defaultZ18-101
l

Phase %s%s
101*constraints2
4.1 2default:default2&
Global Iteration 02default:defaultZ18-101
?
3Phase 4.1 Global Iteration 0 | Checksum: 182d51ca1
*common
‡

%s
*constraints2p
\Time (s): cpu = 00:00:21 ; elapsed = 00:00:20 . Memory (MB): peak = 985.461 ; gain = 119.4382default:default
=
1Phase 4 Rip-up And Reroute | Checksum: 182d51ca1
*common
‡

%s
*constraints2p
\Time (s): cpu = 00:00:21 ; elapsed = 00:00:20 . Memory (MB): peak = 985.461 ; gain = 119.4382default:default
e

Phase %s%s
101*constraints2
5 2default:default2!
Post Hold Fix2default:defaultZ18-101
8
,Phase 5 Post Hold Fix | Checksum: 182d51ca1
*common
‡

%s
*constraints2p
\Time (s): cpu = 00:00:21 ; elapsed = 00:00:20 . Memory (MB): peak = 985.461 ; gain = 119.4382default:default
f

Phase %s%s
101*constraints2
6 2default:default2"
Route finalize2default:defaultZ18-101
9
-Phase 6 Route finalize | Checksum: 182d51ca1
*common
‡

%s
*constraints2p
\Time (s): cpu = 00:00:22 ; elapsed = 00:00:20 . Memory (MB): peak = 985.461 ; gain = 119.4382default:default
m

Phase %s%s
101*constraints2
7 2default:default2)
Verifying routed nets2default:defaultZ18-101
@
4Phase 7 Verifying routed nets | Checksum: 182d51ca1
*common
‡

%s
*constraints2p
\Time (s): cpu = 00:00:22 ; elapsed = 00:00:20 . Memory (MB): peak = 986.738 ; gain = 120.7152default:default
i

Phase %s%s
101*constraints2
8 2default:default2%
Depositing Routes2default:defaultZ18-101
<
0Phase 8 Depositing Routes | Checksum: 10c54f7cd
*common
‡

%s
*constraints2p
\Time (s): cpu = 00:00:22 ; elapsed = 00:00:20 . Memory (MB): peak = 986.738 ; gain = 120.7152default:default
4
Router Completed Successfully
16*routeZ35-16
4
(Ending Route Task | Checksum: 10c54f7cd
*common
‡

%s
*constraints2p
\Time (s): cpu = 00:00:00 ; elapsed = 00:00:20 . Memory (MB): peak = 986.738 ; gain = 120.7152default:default
‡

%s
*constraints2p
\Time (s): cpu = 00:00:00 ; elapsed = 00:00:20 . Memory (MB): peak = 986.738 ; gain = 120.7152default:default
Q
Releasing license: %s
83*common2"
Implementation2default:defaultZ17-83
½
G%s Infos, %s Warnings, %s Critical Warnings and %s Errors encountered.
28*	vivadotcl2
402default:default2
02default:default2
02default:default2
02default:defaultZ4-41
U
%s completed successfully
29*	vivadotcl2 
route_design2default:defaultZ4-42
ü
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2"
route_design: 2default:default2
00:00:232default:default2
00:00:202default:default2
986.7382default:default2
127.1522default:defaultZ17-268
4
Writing XDEF routing.
211*designutilsZ20-211
A
#Writing XDEF routing logical nets.
209*designutilsZ20-209
A
#Writing XDEF routing special nets.
210*designutilsZ20-210
…
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2)
Write XDEF Complete: 2default:default2
00:00:002default:default2 
00:00:00.1102default:default2
986.7382default:default2
0.0002default:defaultZ17-268
G
Running DRC with %s threads
24*drc2
22default:defaultZ23-27
—
#The results of DRC are in file %s.
168*coretcl2Ö
_C:/Users/reliance digiital/HDL_Projects/Assingment3/Assingment3.runs/impl_1/main_drc_routed.rpt_C:/Users/reliance digiital/HDL_Projects/Assingment3/Assingment3.runs/impl_1/main_drc_routed.rpt2default:default8Z2-168
€
UpdateTimingParams:%s.
91*timing2P
< Speed grade: -1, Delay Type: min_max, Constraints type: SDC2default:defaultZ38-91
s
CMultithreading enabled for timing update using a maximum of %s CPUs155*timing2
22default:defaultZ38-191
G
/No user defined clocks was found in the design!216*powerZ33-232
B
,Running Vector-less Activity Propagation...
51*powerZ33-51
G
3
Finished Running Vector-less Activity Propagation
1*powerZ33-1


End Record