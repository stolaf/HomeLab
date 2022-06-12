# echo afuefi.efi %1 /P /B /N /K /R /ME
mv AfuEfix64.smc AfuEfix64.efi
AfuEfix64.efi %1 /P /B /N /K /R /ME
mv AfuEfix64.efi AfuEfix64.smc
