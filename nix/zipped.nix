{
  src,
  runCommand,
  zip,
  ...
}:
runCommand "presentations-zip" {buildInputs = [zip];} ''
  mkdir -p $out
  zip -r $out/presentation.zip ${src}
''
