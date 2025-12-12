📦 Verification Suite
A new test harness script is available: 
ivi-system/scripts/cluster_ui_test.py
.

How to verify:

Compile & Run:
bash
cd ivi-system/apps/cluster-ui
mkdir build && cd build
qt-cmake .. && make
./appcluster-ui
Inject Test Data: Open a new terminal and run:
bash
python3 ../../../scripts/cluster_ui_test.py
Observation: You will see the needles sweep smoothly from 0-120 km/h, the gear shift from P to D, and the center display switch to Navigation mode automatically.
