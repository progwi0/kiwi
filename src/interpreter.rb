#!/usr/bin/env ruby
require_relative './checker'
require 'shellwords'

interpreteCode = ARGV[0]

Dir.chdir(File.dirname(__FILE__))

vars = {}
defs = {}

ex = lambda do |line|
    line = line.strip
    next if line == nil or line.start_with?("::")

    cmd, *opts = Shellwords.split(line)

    case cmd
    when "set"
        name = opts[0]
        val = opts[1..].join(' ')
        vars[name] = val
        ENV[name] = val
    when "msg"
        puts "#{opts.join(' ')}"
    when "out"
        puts "#{vars[opts[0]]}"
    when "add"
        sus = vars[opts[0]].to_i + opts[1].to_i
        vars[opts[0]] = sus
        ENV[opts[0]] = sus.to_s
    when "con"
        sus = vars[opts[0]].to_i - opts[1].to_i
        vars[opts[0]] = sus
        ENV[opts[0]] = sus.to_s
    when "spl"
        sus = vars[opts[0]].to_i / opts[1].to_i
        vars[opts[0]] = sus
        ENV[opts[0]] = sus.to_s
    when "mup"
        sus = vars[opts[0]].to_i * opts[1].to_i
        vars[opts[0]] = sus
        ENV[opts[0]] = sus.to_s
    when "sys"
        system(line.sub(/^sys\s+/, ''))
    when "def"
        name = opts[0]
        val = opts[1..].join(' ')
        defs[name] = line.sub(/^def\s+\S+\s+/, '')
    when "run"
        if defs.key?(opts[0])
            # ex.call(defs[opts[0]])

            opts[1..].each_with_index do |val, i|
                vars["a#{i + 1}"] = val
                ENV["a#{i + 1}"] = val
            end

            ex.call(defs[opts[0]])
        else
            puts "No def like \033[31m#{defs[opts[0]]}\033[0m found, sorry."
            exit 1
        end
    when "imp"
        if File.exist?(opts[0])
            File.readlines("#{opts[0]}", chomp: true).each do |sline|
                ex.call(sline)
            end
        else
            puts "No kiwi like \033[31m#{opts[0]}\033[0m found, sorry."
            exit 1
        end
    when nil
        nil
    when "::"
        nil
    else
        if defs.key?(cmd)
            # ex.call(defs[opts[0]])

            opts[0..].each_with_index do |val, i|
                vars["a#{i + 1}"] = val
                ENV["a#{i + 1}"] = val
            end

            ex.call(defs[cmd])
        else
            puts "No command like \033[31m#{cmd}\033[0m found, sorry."
            exit 1
        end
    end
end

File.foreach("#{interpreteCode}.kw", chomp: true) do |line|
    ex.call(line)
end