function show-manifest {
  if [ -z "$1" ]; then
    for jarFile in `ls -f ./*.jar 2>/dev/null`; do
      echo "Displaying META-INF/MANIFEST.MF from $jarFile"
      unzip -p $jarFile META-INF/MANIFEST.MF
    done
  else
    echo "Displaying META-INF/MANIFEST.MF from $1"
    unzip -p $1 META-INF/MANIFEST.MF
  fi
}
