rem
rem %1 is the input hex
rem %2 is the output hex
rem %3 is the zip source dir
rem
rem cd memzip_files
cd %3
rem zip -0 -r -D C:\devt\arduino\micropython_vs\build\main .
zip -0 -r -D %1.zip .
cd..
rem C:\devt\arduino\arduino-1.0.5\hardware\tools\arm-none-eabi\bin\arm-none-eabi-objcopy -I ihex -O binary build\main.hex build\main.hex.bin
C:\devt\arduino\arduino-1.0.5\hardware\tools\arm-none-eabi\bin\arm-none-eabi-objcopy -I ihex -O binary %1 %1.bin
rem copy /B build\main.hex.bin + /B build\main.zip build\main-mz.hex.bin
copy /B %1.bin + /B %1.zip %2.bin
rem C:\devt\arduino\arduino-1.0.5\hardware\tools\arm-none-eabi\bin\arm-none-eabi-objcopy -I binary -O ihex build\main-mz.hex.bin build\main-mz.hex
C:\devt\arduino\arduino-1.0.5\hardware\tools\arm-none-eabi\bin\arm-none-eabi-objcopy -I binary -O ihex %2.bin %2

