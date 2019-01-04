#!/bin/bash

for file in /Users/alex/Desktop/Work/beat45/audio/45NEW\ RENDER/*
do
  ./calculate_volume.rb "$file" -s
done
