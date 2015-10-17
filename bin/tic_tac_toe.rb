#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# conditional requires
begin
  require 'rubygems'
  require 'bundler/setup'
rescue Exception => e
  STDERR.puts("[!] ignoring #{e.message} - this is is fine if you are not using bundler") if $VERBOSE
end

$LOAD_PATH.push File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))

require 'tic_tac_toe'

def main
  board = TicTacToe::Board.new()
  p1 = TicTacToe::Player.new(name: 'foo', type: TicTacToe::Shared::GameCst::O)
  p2 = TicTacToe::Player.new(name: 'bar', type: TicTacToe::Shared::GameCst::X)      
  game = TicTacToe::Game.new(board, p1, p2)

  game.play
end

main
