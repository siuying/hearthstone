module Hearthstone
  module Log
    class Parser
      STARTUP_REGEX     = /^Initialize engine version/
      GAME_MODE_REGEXP  = /\[Bob\] ---(\w+)---/
      BEGIN_SPECTATOR_REGEX = /\[Power\] .* Begin Spectating/
      END_SPECTATOR_REGEX = /\[Power\] .* End Spectator Mode/
      ARENA_MODE_REGEX = /\[LoadingScreen\] LoadingScreen.OnSceneLoaded\(\) - prevMode=.* currMode=DRAFT/
      RANKED_MODE_REGEX = /.*name=rank_window.*/
      LEGEND_RANK_REGEX = /\[Bob\] legend rank (\d*)/
      GAME_MODE_REGEX = /\[Bob\] ---(\w+)---/
      POWER_TAG_CHANGE_REGEX = /\[Power\] GameState.DebugPrintPower\(\) -\s*TAG_CHANGE Entity=(.*) tag=(.*) value=(.*)/
      GAME_MODE_MAPPINGS = {
        "RegisterScreenPractice" => :practice, 
        "RegisterScreenTourneys" => :casual,
        "RegisterScreenForge" => :arena,
        "RegisterScreenFriendly" => :friendly
      }

      def initialize
      end

      def parse_line(line)
        case line
        when STARTUP_REGEX
          return [:startup]
        when GAME_MODE_REGEX
          mode = GAME_MODE_MAPPINGS[$1]
          return [:mode, mode] if mode
        when BEGIN_SPECTATOR_REGEX
          return [:begin_spectator_mode]
        when END_SPECTATOR_REGEX
          return [:end_spectator_mode]
        when ARENA_MODE_REGEX
          return [:mode, :arena]
        when RANKED_MODE_REGEX
          return [:mode, :ranked]
        when LEGEND_RANK_REGEX
          return [:legend, $1]
        when POWER_TAG_CHANGE_REGEX
          player = $1
          state = $3
          case $2
          when "PLAYER_ID"
            return [:player_id, player, state.to_i]
          when "FIRST_PLAYER"
            return [:first_player, player]
          when "PLAYSTATE"
            return [:game_over, state]
          end
        else
        end
      end
    end
  end
end