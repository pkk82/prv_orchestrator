function show-manifest {
  for jarFile in `ls -f ./*.jar 2>/dev/null`; do
    echo "Displaying META-INF/MANIFEST.MF from $jarFile"
    unzip -p $jarFile META-INF/MANIFEST.MF
  done
}
