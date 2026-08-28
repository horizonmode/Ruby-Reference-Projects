require_relative "../test_helper"
require_relative "../../tasks/tournament/tournament"
require_relative "../../tasks/tournament/fighter"

class TournamentTest < Minitest::Test
  class TrackingFighter < Fighter
    attr_reader :reset_count

    def initialize(**attributes)
      super
      @reset_count = 0
    end

    def reset_for_battle
      super
      @reset_count += 1
    end
  end

  def test_run_battle_returns_and_resets_the_winner
    winner = TrackingFighter.new(name: "Winner", damage: 50, health: 40)
    loser = TrackingFighter.new(name: "Loser", damage: 10, health: 40)
    tournament = Tournament.new([winner, loser])

    result = quietly { tournament.run_battle(winner, loser) }

    assert_same winner, result
    assert_equal 1, winner.reset_count
    assert_equal 0, loser.health
  end

  def test_run_round_advances_a_fighter_with_a_bye
    winner = Fighter.new(name: "Winner", damage: 20, health: 20)
    loser = Fighter.new(name: "Loser", damage: 5, health: 10)
    bye = Fighter.new(name: "Bye", damage: 1, health: 10)
    fighters = [winner, loser, bye]
    tournament = Tournament.new(fighters)

    output, = capture_io do
      fighters.stub(:shuffle!, fighters) do
        @remaining_fighters = tournament.run_round
      end
    end

    assert_equal [winner, bye], @remaining_fighters
    assert_includes output, "Bye gets a bye this round."
  end

  def test_run_returns_the_last_fighter
    fighters = 4.times.map do |index|
      Fighter.new(name: "Fighter #{index + 1}", damage: 10, health: 10)
    end
    tournament = Tournament.new(fighters)

    champion = quietly { tournament.run }

    assert_includes fighters, champion
    assert_predicate champion, :alive?
  end
end
