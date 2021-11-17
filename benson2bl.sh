#!/bin/bash


set -x 
set -e

# top variables
prf_measures="eccen sigma angle varea"
surfaces="white pial sphere inflated"
hemispheres="lh rh"

# make output directories
[ ! -d prf ] && mkdir -p prf prf/prf_surfaces
[ ! -d varea ] && mkdir -p ./varea ./varea_surface
[ ! -d surfaces ] && mkdir -p surfaces surfaces/left surfaces/right
[ ! -d parc_deprecated ] && mkdir -p parc_deprecated

### cleanup
## prf datatype
echo "organizing output"
cp output/surf/*benson14* prf/prf_surfaces/
cp output/mri/*benson14* prf/

# creating surface vtks of freesurfer surfaces
echo "creating vtks"
if [ ! -f prf/prf_surfaces/rh.inflated.vtk ]; then
	for h in ${hemispheres}
	do
		for surf in ${surfaces}
		do
			[ ! -f prf/prf_surfaces/${h}.${surf}.vtk ] && mris_convert --to-scanner ./output/surf/${h}.${surf} prf/prf_surfaces/${h}.${surf}.vtk
		done
	done
fi

# copying and renaming prf files - surface and volume
echo "copying and renaming prf files"
if [ ! -f prf/prf_surfaces/rh.varea ]; then
	for prf in ${prf_measures}
	do
		if [[ ${prf} == "sigma" ]]; then
			output_name="rfWidth"
		elif [[ ${prf} == "angle" ]]; then
			output_name="polarAngle"
		elif [[ ${prf} == "eccen" ]]; then
			output_name="eccentricity"
		else
			output_name=${prf}
		fi

		[ ! -f prf/${output_name}.nii.gz ] && mv prf/*_${prf}.nii.gz prf/${output_name}.nii.gz
		
		if [ -f prf/${output_name} ] && [ -f prf/benson*_${prf}.nii.gz ]; then
			rm -rf prf/benson* prf/prf_surfaces/*benson*
		fi
		
		for h in ${hemispheres}
		do
			[ ! -f prf/prf_surfaces/${h}.${output_name} ] && mv prf/prf_surfaces/${h}.*_${prf} prf/prf_surfaces/${h}.${output_name}
		done
	done
fi

## visual area parcellation -volume
# copy varea parcellation to output directory -volume
[ ! -f varea/parc.nii.gz ] && echo "creating varea parcellation - volume" && cp prf/varea.nii.gz varea/parc.nii.gz && cp template_data/key.txt template_data/label.json ./varea/

## visual area parcellation - surface/data & surface/vertices datatypes
if [ ! -f varea_surface/left.gii ]; then
	echo "creating varea parcellation - surface/data & surface/vertices" 
	for h in ${hemispheres}
	do
		if [[ ${h} == 'lh' ]]; then
			out_h="left"
		else
			out_h="right"
		fi

		# convert parc to gii and cp to output directory
		[ ! -f varea_surface/${out_h}.gii ] && mris_convert -c ./prf/prf_surfaces/${h}.varea ./output/surf/${h}.white varea_surface/${out_h}.gii

		# convert surfaces to gii for surface/vertices datatype
		for surf in ${surfaces}
		do
			if [[ ! ${surf} == "sphere" ]]; then
				[ ! -f ./surfaces/${out_h}/${h}.surf.gii ] && mris_convert ./output/surf/${h}.${surf} ./surfaces/${out_h}/${h}.${surf}.gii
			fi
		done
	done
	[ ! -f varea_surface/label.json ] && cp template_data/label.json varea_surface/label.json 
fi

## visual area parcellation - parcellation/surface -deprecated datatype
if [ ! -f parc_deprecated/lh.parc.annot.gii ]; then
	echo "creating varea parcellation - parcellation/surface - deprecated datatype" 
	for h in ${hemispheres}
	do
		if [[ ${h} == 'lh' ]]; then
			out_h="left"
		else
			out_h="right"
		fi

		# copy and rename freesurfer surfaces
		for surf in ${surfaces}
		do
			if [[ ! ${surf} == "sphere" ]]; then
				[ ! -f parc_deprecated/${h}.parc.${surf}.gii ] && cp surfaces/${out_h}/${h}.${surf}.gii ./parc_deprecated/${h}.parc.${surf}.gii
			fi
		done

		[ ! -f parc_deprecated/${h}.parc.annot.gii ] && mris_convert -c prf/prf_surfaces/${h}.varea ./output/surf/${h}.white ./parc_deprecated/${h}.parc.annot.gii
	done

	[ ! -f parc_deprecated/label.json ] && cp template_data/label.json ./parc_deprecated/
fi

### creating binary mask for visualizer
## volume: NOTE THIS IS NOT ACTUAL R2, BUT JUST NAMED THAT FOR VISUALIZER
[ ! -f prf/R2.nii.gz ] && echo "creating binary mask of visual voxels for visualizer" && mri_binarize --i varea/parc.nii.gz --min 1 --max 100 --o prf/r2.nii.gz

# ## surfaces: NOTE THIS IS NOT ACTUAL R2, BUT JUST NAMED THAT FOR VISUALIZER; cant get conversion to freesurfer binary to work. will just use create_R2 for now
# if [ ! -f prf/prf_surfaces/rh.r2 ]; then
# 	echo "creating binary surface files of visual vertices for visualizer"
# 	for h in ${hemispheres}
# 	do	
# 		if [[ ${h} == 'lh' ]]; then
# 			out_h="left"
# 		else
# 			out_h="right"
# 		fi
# 		[ ! -f prf/prf_surfaces/${h}.r2 ] && mri_binarize --i ./prf/prf_surfaces/${h}.varea --min 1 --max 100 --o ./${h}.r2.gii && mris_convert -c ./${h}.r2.gii ./output/surf/${h}.white ./prf/prf_surfaces/${h}.r2
# 	done
# fi
#if [ ! -f prf/prf_surfaces/rh.r2 ]; then
#	echo "creating binary surface files of visual vertices for visualizer"
#	./create_R2.py ./prf/prf_surfaces/rh.varea ./prf/prf_surfaces/lh.varea
#fi
