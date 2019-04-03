#!/usr/bin/env bash
vagrant up kubemaster;
sleep 1;
echo "vagrat up kubemaster finished"
echo "Will up kubeworker1 and rests"
vagrant up
