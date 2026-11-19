#!/usr/bin/env ruby
require_relative './checker'

interpreteCode = ARGV[0]

Dir.chdir(File.dirname(__FILE__))

vars = {}
defs = {}

ex = lambda do |line|
    line = line.strip
    next if line == nil or line.start_with?("::")

    cmd, *opts = line.split

    case cmd
    when "set"
        name = opts[0]
        val = opts[1..].join(' ')
        vars[name] = val
    when "msg"
        puts "#{opts.join(' ')}"
    when "out"
        puts "#{vars[opts[0]]}"
    when "add"
        sus = vars[opts[0]].to_i + opts[1].to_i
        vars[opts[0]] = sus
    when "con"
        sus = vars[opts[0]].to_i - opts[1].to_i
        vars[opts[0]] = sus
    when "spl"
        sus = vars[opts[0]].to_i / opts[1].to_i
        vars[opts[0]] = sus
    when "mup"
        sus = vars[opts[0]].to_i * opts[1].to_i
        vars[opts[0]] = sus
    when "sys"
        system(opts.join(' '))
    when "def"
        name = opts[0]
        val = opts[1..].join(' ')
        defs[name] = val
    when "run"
        if defs.key?(opts[0])
            ex.call(defs[opts[0]])
        else
            puts "No def like \033[31m#{defs[opts[0]]}\033[0m found, sorry."
        end
    when nil
        nil
    when "::"
        nil
    else
        puts "No command like \033[31m#{cmd}\033[0m found, sorry."
        exit 1
    end
end

File.foreach("#{interpreteCode}.kw", chomp: true) do |line|
    ex.call(line)
end