#!/bin/bash
apt-get update
apt-get install -y docker.io
systemctl start docker 
