#!/bin/bash

set -e

source="$(readlink -f -- $1)"
phh="$source/patches/phh"
pre="$source/patches/pre"

printf "\n##### APPLYING PRE PATCHES #####\n";
sleep 1.0;
for path_pre in $(cd $pre; echo *); do
	tree="$(tr _ / <<<$path_pre | sed -e 's;platform/;;g')"
	printf "\n| $path_pre #####\n";
	[ "$tree" == build ] && tree=build/make
    [ "$tree" == vendor/hardware/overlay ] && tree=vendor/hardware_overlay
    [ "$tree" == treble/app ] && tree=treble_app
	pushd $tree
	
	for patch in $pre/$path_pre/*.patch; do
		# Check if patch is already applied
		if patch -f -p1 --dry-run -R < $patch > /dev/null; then
            printf "##### ALREDY APPLIED: $patch \n";
			continue
		fi

		if git apply --check $patch; then
			git am $patch
		elif patch -f -p1 --dry-run < $patch > /dev/null; then
			#This will fail
			git am $patch || true
			patch -f -p1 < $patch
			git add -u
			git am --continue
		else
			printf "##### FAILED APPLYING: $patch \n"
		fi
	done

	popd
done

printf "\n ##### APPLYING PHH PATCHES #####\n";
sleep 1.0;
for path_phh in $(cd $phh; echo *); do
	tree="$(tr _ / <<<$path_phh | sed -e 's;platform/;;g')"
	printf "\n| $path_phh #####\n";
	[ "$tree" == build ] && tree=build/make
    [ "$tree" == vendor/hardware/overlay ] && tree=vendor/hardware_overlay
    [ "$tree" == treble/app ] && tree=treble_app
	pushd $tree
	
	for patch in $phh/$path_phh/*.patch; do
		# Check if patch is already applied
		if patch -f -p1 --dry-run -R < $patch > /dev/null; then
            printf "##### ALREDY APPLIED: $patch \n";
			continue
		fi

		if git apply --check $patch; then
			git am $patch
		elif patch -f -p1 --dry-run < $patch > /dev/null; then
			#This will fail
			git am $patch || true
			patch -f -p1 < $patch
			git add -u
			git am --continue
		else
			printf "##### FAILED APPLYING: $patch \n"
		fi
	done

	popd
done

rm -rf $1/patches