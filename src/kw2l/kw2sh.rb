#!/usr/bin/env ruby
require 'shellwords'
require 'fileutils'

interpreteCode = ARGV[0]

Dir.chdir(File.dirname(__FILE__))

vars = {}
defs = {}

FileUtils.mkdir_p("build")
File.write("build/out.sh", "")

File.open("build/out.sh", "w") do |f|
    f.puts "#!/bin/sh"
    f.puts "# Transpiled with kw2sh 26.11"
    File.foreach("#{interpreteCode}.kw", chomp: true) do |line|
        line = line.strip

        cmd, *opts = Shellwords.split(line)

        case cmd
        when "msg"
            f.puts "echo #{opts.join(' ')}"
        when "set"
            f.puts "#{opts[0]}=#{opts[1]}"
        when "imp"
            f.puts ". #{opts[0]}"
        when nil
            f.puts ""
        when "::"
            f.puts "# #{opts[0..].join(' ')}"
        when "out"
            f.puts "echo $#{opts[0]}"
        when "add"
            f.puts "#{opts[0]}=$((#{opts[0]} + #{opts[1].to_i}))"
        when "spl"
            f.puts "#{opts[0]}=$((#{opts[0]} / #{opts[1].to_i}))"
        when "con"
            f.puts "#{opts[0]}=$((#{opts[0]} - #{opts[1].to_i}))"
        when "mup"
            f.puts "#{opts[0]}=$((#{opts[0]} * #{opts[1].to_i}))"
        when "def"
            f.puts "#{opts[0]}() {
    #{opts[1..].join(' ')}
}"
        when "run"
            f.puts "#{opts[0]} #{opts[1..].join(' ')}"
        when "sys"
            f.puts "#{opts[0..].join(' ')}"
        end
    end
end