THIS FILE IS INTENDED FOR ARTIFACT EVALUATION PURPOSES.

This artifact contains the code, dataset, experimental results, and reproducibility materials for the paper "Safety Reference Benchmarks with Avoidability Criteria for Evaluating Autonomous Driving Systems."

1. TARGET CATEGORY: Code and Dataset

2. TARGET BADGE: Reproducible  (Available, Reviewed, or Reproducible)

3. INFO
Paper Title: Safety Reference Benchmarks with Avoidability Criteria for Evaluating Autonomous Driving Systems.
Submission ID: 5
Authors: Duong Dinh Tran, Peter Riviere, Takashi Tomita, and Toshiaki Aoki
Affiliation: Japan Advanced Institute of Science and Technology (JAIST), Ishikawa 923-1292, Japan
Emails: {duongtd, priviere, tomita, toshiaki}@jaist.ac.jp

4. EXPECTED BEHAVIOR
The artifact provides a safety benchmark dataset to evaluate ADSs safety under oncoming traffic scenarios, Python code to produce them, and experiment results on Autoware as well as six end-to-end learning-based autonomous driving agents. By running the provided Python code, users can generate the safety benchmark. By following the environment setup and reproduction instructions below, users can reproduce the experiment results.

The code, dataset, experiment results, and their illustrations are also available in this GitHub repository: https://github.com/fomaad/ADS-Safety-Reference-Benchmark.

5. ARTIFACT DESCRIPTION: 
The artifact includes:
- Safety benchmark dataset and code to generate them (Section IV in our paper). They are located in the folder `safety-benchmarks`. There are two types of scenarios: (1) U-turn, where an oncoming vehicle executing a U-turn, and (2) swerving, where an oncoming vehicle temporarily swerving out of its lane to avoid an obstacle. The benchmark is a finite set of concrete scenarios with the corresponding collision-avoidability outcome (Definition 5 in our paper). They are visualized in the PNG figures in the folders `uturn` and `swerve`.

- Experiment results on Autoware (version 0.41.2, https://github.com/autowarefoundation/autoware) against the safety reference benchmarks, conducted using the AWSIM-Labs simulator. They are located in the folder `Autoware-baseline-results`. The results includes simulation trace data (in JSON format, non-replayable), camera videos, and input scripts to simulate all driving scenarios in these experiments.

- Experiment results on six end-to-end learning-based autonomous driving agents (Section V.C in our paper), conducted using the CARLA simulator. They are located in the folder `CARLA-agents-results`. The results include replayable log files and JSON trace data.

- Experiment results on Autoware when integrating with a controller safety shield. They are located in the folder `Autoware-shielding-results`. The contents are similar to the folder `Autoware-baseline-results`.

6. ENVIRONMENT SETUP
6.1. Safety benchmark dataset
A normal PC can be used to run the code to produce the safety benchmark dataset. All we need is a Python environment with `numpy` and `matplotlib` installed, which can be done by running the following command from the folder `safety-benchmarks`:

```
pip install -r requirements.txt
```

6.2. End-to-end driving agents experiments
The requirements to run these driving agents with CARLA simulator are as follows:
- Minimum RAM: 16 GB
- Minimum GPU: NVIDIA GeForce RTX 2070 with at least 8 GB of VRAM
- NVIDIA driver installed
- Docker installed
(We run all the experiments on a PC with Ubuntu 22.04 OS, Intel Core i7-14700K CPU, 96 GB RAM, and NVIDIA GeForce RTX 4070 Ti GPU.)

We provide some Docker images for running the driving agents (and Autoware) experiments, and we recommend to use this Docker environment.
In addition to Docker installation, the Nvidia container toolkit needs to be installed. This is required to run docker with GPU support (pass through NVIDIA GPU from host to a Docker container). 
More information can be found at: https://github.com/NVIDIA/nvidia-container-toolkit.

The installation instructions are available here: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/1.19.1/install-guide.html. Make sure to complete the step "Configuring Docker" and restart the Docker daemon after the installation.

Once the setup of Nvidia container toolkit finishes, pull the CARLA simulator (version 0.9.15) docker image from Docker Hub:
```
docker pull duongtd23/carla-server:latest
```

Note that due to the large size of the docker image(s), we cannot encapsulate them directly in this artifact.
Note also that CARLA also provides a docker image (carlasim/carla:0.9.15), but it does not include additional maps that are required for our experiments. Our image above includes such maps.

Then, pull another docker image that contains code to run the driving agents:
```
docker pull duongtd23/carla-agent:latest
```

6.3. Autoware experiments
The following is environment setup to reproduce the experiment results on Autoware (both the baseline and the shielding versions).
The requirements to run the Autoware experiments with AWSIM-Labs simulator are as follows:
- OS: Ubuntu (recommend 22.04 or 24.04)
- CPU: 6 cores and 12 threads or higher
- Minimum RAM: 32 GB
- Minimum GPU: NVIDIA GeForce RTX 2080 Ti
- Nvidia driver version: 570 or higher
- Nvidia container toolkit installed (see Section 6.2)

ROS 2 needs to be installed as well. The instructions to install ROS Humble on Ubuntu 22.04 can be found at: https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debs.html
In addition, for the best performance, DDS needs to be tuned for the best performance (reference: https://docs.autoware.org/1.5.0/installation/additional-settings-for-developers/network-configuration/dds-settings/). To do so, first, make sure that `ros-humble-rmw-cyclonedds-cpp` package was installed:
```
sudo apt install ros-humble-rmw-cyclonedds-cpp
```

Add the following lines to `~/.bashrc` file:
```
if [ ! -e /tmp/cycloneDDS_configured ]; then
    sudo sysctl -w net.core.rmem_max=2147483647
    sudo sysctl -w net.ipv4.ipfrag_time=3
    sudo sysctl -w net.ipv4.ipfrag_high_thresh=134217728     # (128 MB)
    sudo ip link set lo multicast on
    touch /tmp/cycloneDDS_configured
fi
```

Save the following as `cyclonedds.xml` in your home directory `~`:
```
<?xml version="1.0" encoding="UTF-8" ?>
<CycloneDDS xmlns="https://cdds.io/config" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="https://cdds.io/config https://raw.githubusercontent.com/eclipse-cyclonedds/cyclonedds/master/etc/cyclonedds.xsd">
    <Domain Id="any">
        <General>
            <Interfaces>
                <NetworkInterface name="lo" priority="default" multicast="default" />
            </Interfaces>
            <AllowMulticast>default</AllowMulticast>
            <MaxMessageSize>65500B</MaxMessageSize>
        </General>
        <Internal>
            <SocketReceiveBufferSize min="10MB"/>
            <Watermarks>
                <WhcHigh>500kB</WhcHigh>
            </Watermarks>
        </Internal>
    </Domain>
</CycloneDDS>
```

Add the following lines are added to the `~/.bashrc` file:
```
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export CYCLONEDDS_URI=/home/<your_username>/cyclonedds.xml
```

Make sure to replace `<your_username>` with your actual username (absolute path is required there).
To make these changes effective, reboot the PC.

Now, pull the docker image that contains compiled Autoware and the AWSIM-Labs simulator:
```
docker pull duongtd23/autoware-awsimlabs:latest
```

7. GETTING STARTED
7.1. Safety benchmark dataset
From the folder `safety-benchmarks`, run the following command to generate the safety benchmark dataset for the U-turn scenarios.
```
python -m uturn.uturn
```

There are two optional arguments: `-vo` to specify the NPC speed in km/h (default: 10), and `-l` to specify the lane type, either `rightmost` or `adjacent` (default: rightmost). Use option `-h` to see the help message.

Similarly with the swerve scenarios, run the following command to generate the safety benchmark dataset.
```
python -m swerve.swerve
```

We also provide code to animate the motions of the two vehicles in a given concrete scenario. This allows users to validate/debug the simulation and/or the benchmark results. For example, the following command produces an animation for a concrete U-turn scenario where the ego speed is 20 km/h, the NPC speed is 10 km/h, the ego travels in the lane adjacent to the rightmost lane, and the initial longitudinal distance between them is 25 m:

```
python -m uturn.visualization -vo 10 -ve 20 -dx0 25 --lane adjacent
```

An animation will be generated. Use the `-h` option to see the help message.

7.2. End-to-end driving agents experiments
The recorded log files of the experiments on the six end-to-end driving agents are replayable in the CARLA simulator. In folder `CARLA-agents-results/u-turn`, these log files are named as `uturn_<agentid>_<lane>_<vo>.log`, where `<lane>` can be either `innermost` or `adjacent`, `<vo>` is the NPC speed in km/h, and `<agentid>` can be one of the following:
- `if_if`: InterFuser
- `lav_lav`: Learning from All Vehicles
- `tf_tf`: TransFuser
- `tl_ltf`: Latent TransFuser
- `tf_gf`: Geometric Fusion
- `tf_lf`: Late Fusion

In folder `CARLA-agents-results/swerve`, these log files are named as `swerve_<agentid>_<vo>_<vy>.log`, where `<vo>` is the NPC speed in km/h, and `<vy>` is the lateral velocity.

To replay the recorded log files in CARLA simulator, first, run the docker container for CARLA simulator in one terminal:
```
docker run --runtime=nvidia --gpus all -it --net=host --env=DISPLAY=$DISPLAY --env=NVIDIA_VISIBLE_DEVICES=all --env=NVIDIA_DRIVER_CAPABILITIES=all --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" carla-server:latest bash
```

Then, run the CARLA simulator inside the container:
```
./CarlaUE4.sh
```

A new window should appear in your host display. In another terminal, start the docker container for the driving agents:
```
docker run --runtime=nvidia --gpus all -it --net=host duongtd23/carla-agent:latest bash
```

Then, use our provided Python script to replay a recorded log file:
```
python replay.py <absolute-path-to-log-file>
```

Inside the container, the log files are located in folders `u-turn` and `swerve` in the workspace folder. Make sure to use the absolute path to the log file. A relative path will not work since CARLA will look for the file from the server side. For example:
```
python replay.py /workspace/u-turn/run1/uturn_if_if_adjacent_10.log
```

More options for the replay script can be viewed by using option -h.

8. REPRODUCIBILITY
8.1. End-to-end driving agents experiments
We use the PCLA framework to run the experiments with the six end-to-end driving agents (see https://github.com/MasoudJTehrani/PCLA/tree/6bd8679ddebb7ab630b8df2710d9062b06c15c84):

Python scripts  are provided in the `carla-agent` docker container to run the experiments (i.e, U-turn and swerve scenarios) with different agents. For example, to run the U-turn scenario with InterFuser agent, inside the `carla-agent` container, run the following command:

```
python uturn.py --agent if_if <path/to/save/log>
```

Make sure to start the CARLA server from the `carla-server` container before running the above command. Use `--help` option to view all available options. Note that the single command above will execute multiple scenarios sequentially (under different lane positions, speeds). When a scenario terminates (i.e., when the ego vehicle reaches its goal or type `Ctrl+C`), the recorded data will be saved to the specified path with incremental numbering.

8.2. Autoware experiments
Once complete the environment setup in Section 6.3, run the following command to launch the Docker container for Autoware and AWSIM-Labs simulator:
```
./run_autoware_docker.sh
```

(Since the docker run command is long, we encapsulate it in a shell script.)

Then, connect more three terminals to the container by running the following command in each terminal:
```
docker exec -it <container> bash
```
Replace `<container>` with the container id, which can be found by running `docker ps` command.

In terminal #1, launch AWSIM-Labs:
```
/awsim/awsim_labs.x86_64 -noise false
```

Note that the option `-noise false` disables Gaussian noise in the simulated data from LiDAR sensors. By default, noise is enabled.
A new window should appear (see some figures here for reference: https://autowarefoundation.github.io/AWSIM-Labs/main/GettingStarted/QuickStartDemo/)

In terminal #2, launch Autoware:
```
source install/setup.bash
ros2 launch autoware_launch e2e_simulator.launch.xml vehicle_model:=awsim_labs_vehicle sensor_model:=awsim_labs_sensor_kit map_path:=/autoware_map/nishishinjuku_autoware_map launch_vehicle_interface:=true
```
A new window should appear. The localization mode (in the top-left window) should changes to "Initializing" and then eventually to "Initialized" (meaning that Autoware and AWSIM-Labs are successfully connected).

In terminal #3, we will run the AW-Runtime-Monitor to record the simulation traces, and to enable/disable the controller safety shield.
```
source install/setup.bash
cd /AW-Runtime-Monitor/
source .venv/bin/activate
python main.py -o <path-to-folder-to-save-traces> -v false
```

where the option `-v false` disable shielding. By default, it is enabled.
For more details about the tool usage, use option -h.

In terminal #4, we will run the AWSIM-Script to execute desired driving scenarios. AWSIM-Script will act as a client to send scenario specifications to the AWSIM-Labs simulator server. The scenario specification are in *.script file format, and can be found in folder `Autoware-baseline-results/u-turn/scripts` for U-turn scenarios, and in folder `Autoware-baseline-results/swerve/scripts` for swerve scenarios in this artifact (while in the container, they are located in folder /scenarios).

For example, to execute U-turn scenarios when the ego vehicle travels on the adjacent lane to the rightmost lane, run the following command:

```
source install/setup.bash
cd /AWSIM-Script
python script_file_manager.py /scenarios/u-turn/adjacent-lane
```

Each scenario in the folder will be executed sequentially. When a scenario terminates (i.e., when the ego vehicle reaches its goal), the recorded data will be saved to folder `<path-to-folder-to-save-traces>` (provided when running AW-Runtime-Monitor) with incremental numbering.

9. WITHOUT USING DOCKER
Without using Docker, the experiments with six end-to-end driving agents can be run by following the instructions here: https://github.com/fomaad/ADS-Safety-Reference-Benchmark/tree/main/CARLA-agents-results.
The experiments with Autoware can be run by following the instructions here: https://github.com/fomaad/ADS-Safety-Reference-Benchmark/tree/main/Autoware-baseline-results.