#!/usr/bin/env python

import numpy as np
import nibabel as nib
import nibabel.freesurfer.io as fsio
import os
import sys

def create_R2(in_rh_surf, in_lh_surf):
  
  data = fsio.read_morph_data(in_rh_surf)
  for i in range(data.shape[0]):
    if data[i] > 0.0:
      data[i] = 1.0
  fsio.write_morph_data(os.path.join(os.getcwd(),'prf','prf_surfaces','rh.r2'),data)

  data = fsio.read_morph_data(in_lh_surf)
  for i in range(data.shape[0]):
    if data[i] > 0.0:
      data[i] = 1.0
  fsio.write_morph_data(os.path.join(os.getcwd(),'prf','prf_surfaces','lh.r2'),data)


if __name__ == '__main__':
  create_R2(sys.argv[1], sys.argv[2])