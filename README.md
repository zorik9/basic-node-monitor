# Node Monitor Demo

Demo of running Prometheus, node-exporter, Graphite and Grafana in docker containers, using docker compose

## Description

This project is a starting point for configuring monitoring system in a single node.

The monitored components are: C.P.U, Memory and disk usage.
This is just an entry point. So it can be extended to support more metrics components.

prometheus is recording real time metrics.
that are integrated with grafana, which is the visualization tool,
for displaying the graphs of C.P.U, Memory and disk usage
Prometheus exporter for hardware and OS metrics exposed by *NIX kernels.
Therefore, the monitoring will be performed, by using node-exporter,
since the components are running inside docker containers.


### Dependencies
docker
curl
docker-compose

The stack was tested in ubuntu 16.04, and was design to run on UNIX like system (Linux\MacOS)


### Installing

To provision your machine, Run setup.bash
the setup script will handle permissions, and install all of the dependencies in your machine.

After a successfull setup you should see the following message in the console:
====================================
Setup has been successfully finished
====================================


After setting up your environment, run install.bash
This script will clean the environment, install the dependencies,
and create new environment, with docker-compose,
that consist of the stack: prometheus, grafana and node-exporter.


### Executing program

After the environment is up, run the script update-dashboard.sh in a new shell.
This script will build the desired dashboard, according to the configuration file: grafana\dashboards\dashboard.txt


### Usage

You can access prometheus at localhost:9090
You can access grafana at localhost:3000
login as admin:admin
go to to the menu: Dashboards->manage
click on Basic Monitor Overview
The desired dashboard with C.P.U, Memory and disk usage monitoring will be opened.
After acceesing the monitor it will be available in the Home page.

You can also update or add more panels, by configuring the file grafana\dashboards\dashboard.txt
After configuring this file, You should run the update-dashboard.sh script, and refresh grafana.


The basic-node-monitor is available on github --> https://github.com/zorik9/basic-node-monitor

Make sure to delete large log files, or add crontab to automatically clean the log files.


## Help

In case of bugs, need for help, or wish to contribute:
Please send an email to zorik9@gmail.com or open new issue on https://github.com/zorik9/basic-node-monitor

Any advise for common problems or issues.


### TODO
1. Add mechanism to clean log files
2. Generate grafana\dashboards\dashboard.txt, by using smaller reusable configurations
3. Add graphite to the stack.


## Authors

Shahar Rotshtein	zorik9@gmail.com
