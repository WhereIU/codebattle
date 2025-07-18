defmodule Codebattle.Tournament.Entire.Top200Test do
  use Codebattle.DataCase, async: false

  import Codebattle.Tournament.Helpers
  import Codebattle.TournamentTestHelpers

  alias Codebattle.Game
  alias Codebattle.PubSub.Message
  alias Codebattle.Repo
  alias Codebattle.Tournament
  alias Codebattle.Tournament.TournamentResult

  @tag :skip
  test "works with top200" do
    %{id: t1_id} = insert(:task, level: "easy", name: "t1")
    %{id: t2_id} = insert(:task, level: "easy", name: "t2")
    %{id: t3_id} = insert(:task, level: "easy", name: "t3")
    %{id: t4_id} = insert(:task, level: "easy", name: "t4")
    %{id: t5_id} = insert(:task, level: "easy", name: "t5")
    %{id: t6_id} = insert(:task, level: "easy", name: "t6")
    %{id: t7_id} = insert(:task, level: "easy", name: "t7")
    %{id: t8_id} = insert(:task, level: "easy", name: "t8")
    %{id: t9_id} = insert(:task, level: "easy", name: "t9")
    %{id: t10_id} = insert(:task, level: "easy", name: "t10")
    %{id: t11_id} = insert(:task, level: "easy", name: "t11")
    %{id: t12_id} = insert(:task, level: "easy", name: "t12")
    %{id: t13_id} = insert(:task, level: "easy", name: "t13")
    %{id: t14_id} = insert(:task, level: "easy", name: "t14")

    insert(:task_pack, name: "tp1", task_ids: [t1_id, t2_id])
    insert(:task_pack, name: "tp2", task_ids: [t3_id, t4_id])
    insert(:task_pack, name: "tp3", task_ids: [t5_id, t6_id])
    insert(:task_pack, name: "tp4", task_ids: [t7_id, t8_id])
    insert(:task_pack, name: "tp5", task_ids: [t9_id, t10_id])
    insert(:task_pack, name: "tp6", task_ids: [t11_id, t12_id])
    insert(:task_pack, name: "tp7", task_ids: [t13_id, t14_id])

    %{id: c1_id} = insert(:clan, name: "c1")
    %{id: c2_id} = insert(:clan, name: "c2")
    %{id: c3_id} = insert(:clan, name: "c3")
    %{id: c4_id} = insert(:clan, name: "c4")
    %{id: c5_id} = insert(:clan, name: "c5")
    %{id: c6_id} = insert(:clan, name: "c6")
    %{id: c7_id} = insert(:clan, name: "c7")
    %{id: c8_id} = insert(:clan, name: "c8")
    %{id: c9_id} = insert(:clan, name: "c9")
    creator = insert(:user)
    user1 = %{id: u1_id} = insert(:user, %{clan_id: c1_id, clan: "c1", name: "u1", subscription_type: :premium})
    user2 = %{id: u2_id} = insert(:user, %{clan_id: c2_id, clan: "c2", name: "u2", subscription_type: :premium})
    user3 = %{id: u3_id} = insert(:user, %{clan_id: c3_id, clan: "c3", name: "u3", subscription_type: :premium})
    user4 = %{id: u4_id} = insert(:user, %{clan_id: c4_id, clan: "c4", name: "u4", subscription_type: :premium})
    user5 = %{id: u5_id} = insert(:user, %{clan_id: c5_id, clan: "c5", name: "u5", subscription_type: :premium})
    user6 = %{id: u6_id} = insert(:user, %{clan_id: c6_id, clan: "c6", name: "u6", subscription_type: :premium})
    user7 = %{id: u7_id} = insert(:user, %{clan_id: c7_id, clan: "c7", name: "u7", subscription_type: :premium})
    user8 = %{id: u8_id} = insert(:user, %{clan_id: c8_id, clan: "c8", name: "u8", subscription_type: :premium})
    rest_users = insert_list(183, :user, clan: "c", subscription_type: :premium)
    user9 = %{id: u9_id} = insert(:user, %{clan_id: c9_id, clan: "c9", name: "u9", subscription_type: :premium})

    {:ok, tournament = %{id: t_id}} =
      Tournament.Context.create(%{
        "starts_at" => "2022-02-24T06:00",
        "name" => "Top 200",
        "user_timezone" => "Etc/UTC",
        "level" => "easy",
        "task_pack_name" => "tp1,tp2,tp3,tp4,tp5,tp6,tp7",
        "creator" => creator,
        "break_duration_seconds" => 100,
        "task_provider" => "task_pack_per_round",
        "task_strategy" => "sequential",
        "round_timeout_seconds" => 100,
        "ranking_type" => "by_percentile",
        "type" => "top200",
        "state" => "waiting_participants",
        "rounds_limit" => "7",
        "use_clan" => "false",
        "players_limit" => 200
      })

    users = [user1, user2, user3, user4, user5, user6, user7, user8, user9] ++ rest_users
    admin_topic = tournament_admin_topic(tournament.id)
    common_topic = tournament_common_topic(tournament.id)
    player1_topic = tournament_player_topic(tournament.id, u1_id)
    player2_topic = tournament_player_topic(tournament.id, u2_id)
    player3_topic = tournament_player_topic(tournament.id, u3_id)
    player4_topic = tournament_player_topic(tournament.id, u4_id)
    player5_topic = tournament_player_topic(tournament.id, u5_id)
    player6_topic = tournament_player_topic(tournament.id, u6_id)
    player7_topic = tournament_player_topic(tournament.id, u7_id)
    player8_topic = tournament_player_topic(tournament.id, u8_id)
    player9_topic = tournament_player_topic(tournament.id, u9_id)

    Codebattle.PubSub.subscribe(admin_topic)
    Codebattle.PubSub.subscribe(common_topic)
    Codebattle.PubSub.subscribe(player1_topic)
    Codebattle.PubSub.subscribe(player2_topic)
    Codebattle.PubSub.subscribe(player3_topic)
    Codebattle.PubSub.subscribe(player4_topic)
    Codebattle.PubSub.subscribe(player5_topic)
    Codebattle.PubSub.subscribe(player6_topic)
    Codebattle.PubSub.subscribe(player7_topic)
    Codebattle.PubSub.subscribe(player8_topic)
    Codebattle.PubSub.subscribe(player9_topic)

    ## JOIN USERS ##
    Tournament.Server.handle_event(tournament.id, :join, %{users: users})

    Enum.each(users, fn %{id: id, name: name} ->
      assert_received %Message{
        topic: ^common_topic,
        event: "tournament:player:joined",
        payload: %{player: %{name: ^name, id: ^id, state: "active"}}
      }
    end)

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    Tournament.Server.handle_event(tournament.id, :start, %{
      user: creator,
      time_step_ms: 20_000,
      min_time_sec: 0
    })

    assert_received %Message{
      topic: ^admin_topic,
      event: "tournament:updated",
      payload: %{
        tournament: %{
          state: "active",
          current_round_position: 0,
          break_state: "off",
          last_round_ended_at: nil,
          last_round_started_at: _
        }
      }
    }

    assert_received %Message{
      topic: ^common_topic,
      event: "tournament:round_created",
      payload: %{
        tournament: %{
          state: "active",
          current_round_position: 0,
          break_state: "off",
          last_round_ended_at: nil,
          last_round_started_at: _
        }
      }
    }

    [game_id1, game_id2, game_id3, game_id4, game_id5, game_id6, game_id7, game_id8, game_id9] =
      get_users_active_games([u1_id, u2_id, u3_id, u4_id, u5_id, u6_id, u7_id, u8_id, u9_id])

    assert_players_received_games_with_task(
      t1_id,
      [
        {player1_topic, game_id1},
        {player2_topic, game_id2},
        {player3_topic, game_id3},
        {player4_topic, game_id4},
        {player5_topic, game_id5},
        {player6_topic, game_id6},
        {player7_topic, game_id7},
        {player8_topic, game_id8},
        {player9_topic, game_id9}
      ],
      "playing"
    )

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}
    tournament = Tournament.Context.get(tournament.id)

    # Verify initial tournament state
    assert players_count(tournament) == 192
    assert_total_playing_matches(tournament, 96)

    # Verify matches are created correctly - 100 matches for 200 players
    matches = Tournament.Helpers.get_matches(tournament, "playing")
    assert Enum.count(matches) == 96
    assert Enum.all?(matches, fn match -> match.state == "playing" end)

    assert %{
             entries: [
               %{id: ^u1_id, score: 0, place: 1},
               %{id: ^u2_id, score: 0, place: 2},
               %{id: ^u3_id, score: 0, place: 3},
               %{id: ^u4_id, score: 0, place: 4},
               %{id: ^u5_id, score: 0, place: 5},
               %{id: ^u6_id, score: 0, place: 6},
               %{id: ^u7_id, score: 0, place: 7},
               %{id: ^u8_id, score: 0, place: 8},
               %{id: ^u9_id, score: 0, place: 9}
               | _rest
             ]
           } = Tournament.Ranking.get_page(tournament, 1)

    ##### Round 1, Game 1: users won the game
    win_active_match(tournament, user1, %{opponent_percent: 33, duration_sec: 10})
    win_active_match(tournament, user2, %{opponent_percent: 33, duration_sec: 20})
    win_active_match(tournament, user3, %{opponent_percent: 33, duration_sec: 30})
    win_active_match(tournament, user4, %{opponent_percent: 33, duration_sec: 40})
    win_active_match(tournament, user5, %{opponent_percent: 33, duration_sec: 50})
    win_active_match(tournament, user6, %{opponent_percent: 33, duration_sec: 60})
    win_active_match(tournament, user7, %{opponent_percent: 33, duration_sec: 70})
    win_active_match(tournament, user8, %{opponent_percent: 33, duration_sec: 100})

    TournamentResult.upsert_results(tournament)
    Tournament.Ranking.set_ranking(tournament)
    :timer.sleep(200)

    assert %{
             entries: [
               %{name: "u1", place: 1, score: 55, clan: "c1", clan_id: ^c1_id, id: ^u1_id},
               %{name: "u2", place: 2, score: 52, clan: "c2", clan_id: ^c2_id, id: ^u2_id},
               %{name: "u3", place: 3, score: 49, clan: "c3", clan_id: ^c3_id, id: ^u3_id},
               %{name: "u4", place: 4, score: 46, clan: "c4", clan_id: ^c4_id, id: ^u4_id},
               %{name: "u5", place: 5, score: 43, clan: "c5", clan_id: ^c5_id, id: ^u5_id},
               %{name: "u6", place: 6, score: 40, clan: "c6", clan_id: ^c6_id, id: ^u6_id},
               %{name: "u7", place: 7, score: 37, clan: "c7", clan_id: ^c7_id, id: ^u7_id},
               %{name: "u8", place: 8, score: 28, clan: "c8", clan_id: ^c8_id, id: ^u8_id}
               | _rest
             ]
           } = Tournament.Ranking.get_page(tournament, 1)

    assert_players_received_games_with_task(
      t1_id,
      [
        {player1_topic, game_id1},
        {player2_topic, game_id2},
        {player3_topic, game_id3},
        {player4_topic, game_id4},
        {player5_topic, game_id5},
        {player6_topic, game_id6},
        {player7_topic, game_id7},
        {player8_topic, game_id8}
      ],
      "game_over"
    )

    ### should be rematch with same user
    :timer.sleep(100)

    [game_id1, game_id2, game_id3, game_id4, game_id5, game_id6, game_id7, game_id8] =
      get_users_active_games([u1_id, u2_id, u3_id, u4_id, u5_id, u6_id, u7_id, u8_id])

    assert_players_received_games_with_task(
      t2_id,
      [
        {player1_topic, game_id1},
        {player2_topic, game_id2},
        {player3_topic, game_id3},
        {player4_topic, game_id4},
        {player5_topic, game_id5},
        {player6_topic, game_id6},
        {player7_topic, game_id7},
        {player8_topic, game_id8}
      ],
      "playing"
    )

    for _ <- 1..8 do
      assert_received %Message{
        topic: ^admin_topic,
        event: "tournament:updated",
        payload: %{
          tournament: %{current_round_position: 0}
        }
      }
    end

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    ##### Round 1, Game 2: All users win their second game
    tournament = Tournament.Context.get(tournament.id)
    win_active_match(tournament, user1, %{opponent_percent: 0, duration_sec: 100})
    win_active_match(tournament, user2, %{opponent_percent: 0, duration_sec: 200})
    win_active_match(tournament, user3, %{opponent_percent: 0, duration_sec: 300})
    win_active_match(tournament, user4, %{opponent_percent: 0, duration_sec: 400})
    win_active_match(tournament, user5, %{opponent_percent: 0, duration_sec: 500})
    win_active_match(tournament, user6, %{opponent_percent: 0, duration_sec: 600})
    win_active_match(tournament, user7, %{opponent_percent: 0, duration_sec: 700})
    win_active_match(tournament, user8, %{opponent_percent: 0, duration_sec: 800})

    :timer.sleep(200)
    # Verify match states after second game wins
    tournament_after_game2 = Tournament.Context.get(tournament.id)

    # Verify no more active matches for these users in round 1
    active_matches = Tournament.Helpers.get_matches(tournament_after_game2, "playing")

    assert Enum.count(
             Enum.filter(active_matches, fn m ->
               Enum.any?(m.player_ids, fn p_id -> p_id in [u1_id, u2_id, u3_id, u4_id, u5_id, u6_id, u7_id, u8_id] end)
             end)
           ) == 0

    :timer.sleep(100)
    TournamentResult.upsert_results(tournament)
    Tournament.Ranking.set_ranking(tournament)
    :timer.sleep(100)

    assert %{
             entries: [
               %{name: "u1", place: 1, score: 605, clan: "c1"},
               %{name: "u2", place: 2, score: 563, clan: "c2"},
               %{name: "u3", place: 3, score: 520, clan: "c3"},
               %{name: "u4", place: 4, score: 478, clan: "c4"},
               %{name: "u5", place: 5, score: 436, clan: "c5"},
               %{name: "u6", place: 6, score: 394, clan: "c6"},
               %{name: "u7", place: 7, score: 351, clan: "c7"},
               %{name: "u8", place: 8, score: 303, clan: "c8"} | _
             ]
           } = Tournament.Ranking.get_page(tournament, 1)

    assert_players_received_games_with_task(
      t2_id,
      [
        {player1_topic, game_id1},
        {player2_topic, game_id2},
        {player3_topic, game_id3},
        {player4_topic, game_id4},
        {player5_topic, game_id5},
        {player6_topic, game_id6},
        {player7_topic, game_id7},
        {player8_topic, game_id8}
      ],
      "game_over"
    )

    ### should not be rematch, cause round finished
    :timer.sleep(200)
    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    ###### Finish Round 1
    # Verify initial results count before finishing round
    assert Repo.count(TournamentResult) == 32

    # Finish the round and wait for processing
    Tournament.Server.finish_round_after(tournament.id, tournament.current_round_position, 0)
    :timer.sleep(600)

    # Verify results were created for all players
    assert Repo.count(TournamentResult) == 208

    assert %{
             "current_round" => 1,
             "players" => [p1, p2, p3, p4, p5, p6, p7, p8, p9 | _] = players,
             "tournament_id" => ^t_id
           } = Tournament.Helpers.get_player_ranking_stats(tournament)

    {active, bottom} = Enum.split_with(players, &(&1["active"] == 1))
    assert Enum.count(active) == 128
    assert Enum.count(bottom) == 64
    assert %{"active" => 0, "total_score" => 0, "won_tasks" => 0, "rank" => 192} = List.last(players)

    assert %{
             "active" => 1,
             "clan_id" => _,
             "history" => [
               %{
                 round: 1,
                 score: 605,
                 opponent_id: _,
                 opponent_clan_id: _,
                 player_win_status: true,
                 solved_tasks: ["won", "won"]
               }
             ],
             "id" => _,
             "name" => "u1",
             "rank" => 1,
             "returned" => 0,
             "total_score" => 605,
             "total_tasks" => 2,
             "win_prob" => _,
             "won_tasks" => 2
           } = p1

    assert %{
             "active" => 1,
             "clan_id" => _,
             "history" => [
               %{
                 round: 1,
                 score: 563,
                 opponent_id: _,
                 opponent_clan_id: _,
                 player_win_status: true,
                 solved_tasks: ["won", "won"]
               }
             ],
             "id" => _,
             "name" => "u2",
             "rank" => 2,
             "returned" => 0,
             "total_score" => 563,
             "total_tasks" => 2,
             "win_prob" => _,
             "won_tasks" => 2
           } = p2

    assert %{"active" => 1, "rank" => 3, "total_score" => 520} = p3
    assert %{"active" => 1, "rank" => 4, "total_score" => 478} = p4
    assert %{"active" => 1, "rank" => 5, "total_score" => 436} = p5
    assert %{"active" => 1, "rank" => 6, "total_score" => 394} = p6
    assert %{"active" => 1, "rank" => 7, "total_score" => 351} = p7
    assert %{"active" => 1, "rank" => 8, "total_score" => 303, "history" => [_]} = p8
    assert %{"active" => 1, "rank" => 9, "history" => [], "won_tasks" => 0} = p9

    # Verify tournament state after round finish
    tournament_after_round1 = Tournament.Context.get(tournament.id)
    assert tournament_after_round1.current_round_position == 0
    assert tournament_after_round1.break_state == "on"

    # Verify no active matches exist after round finish
    assert Enum.empty?(Tournament.Helpers.get_matches(tournament_after_round1, "playing"))

    assert_received %Message{
      topic: ^common_topic,
      event: "tournament:round_finished",
      payload: %{
        tournament: %{
          type: "top200",
          state: "active",
          current_round_position: 0,
          break_state: "on",
          last_round_ended_at: _,
          last_round_started_at: _,
          show_results: true
        }
      }
    }

    assert_received %Message{
      topic: ^admin_topic,
      event: "tournament:updated",
      payload: %{
        tournament: %{
          type: "top200",
          state: "active",
          current_round_position: 0,
          break_state: "on",
          last_round_ended_at: _,
          last_round_started_at: _,
          show_results: true
        }
      }
    }

    assert_received %Message{
      topic: ^player9_topic,
      event: "tournament:match:upserted",
      payload: %{
        match: %{state: "timeout"},
        players: [%{}, %{}]
      }
    }

    assert_received %Message{
      topic: ^admin_topic,
      event: "tournament:updated",
      payload: %{
        tournament: %{
          type: "top200",
          state: "active",
          current_round_position: 0,
          break_state: "on",
          last_round_ended_at: _,
          last_round_started_at: _,
          show_results: true
        }
      }
    }

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    ##### End Round 1 break and Start Round 2
    tournament = Tournament.Context.get(tournament.id)
    Tournament.Server.stop_round_break_after(tournament.id, tournament.current_round_position, 0)
    :timer.sleep(600)

    # Verify 100 matches were created for round 2
    assert_total_playing_matches(tournament, 96)

    # Verify tournament state after round 2 start
    tournament_round2 = Tournament.Context.get(tournament.id)
    assert tournament_round2.current_round_position == 1
    assert tournament_round2.break_state == "off"

    # Verify all players have been assigned to matches
    round2_matches = Tournament.Helpers.get_matches(tournament_round2, "playing")
    player_ids_in_matches = Enum.flat_map(round2_matches, & &1.player_ids)
    assert Enum.count(player_ids_in_matches) == 192

    assert_received %Message{
      topic: ^common_topic,
      event: "tournament:round_created",
      payload: %{
        tournament: %{
          state: "active",
          current_round_position: 1,
          break_state: "off",
          last_round_ended_at: _,
          last_round_started_at: _
        }
      }
    }

    assert_received %Message{
      topic: ^admin_topic,
      event: "tournament:updated",
      payload: %{
        tournament: %{
          state: "active",
          current_round_position: 1,
          break_state: "off",
          last_round_ended_at: _,
          last_round_started_at: _
        }
      }
    }

    [game_id1, game_id2, game_id3, game_id4, game_id5, game_id6, game_id7, game_id8, game_id9] =
      get_users_active_games([u1_id, u2_id, u3_id, u4_id, u5_id, u6_id, u7_id, u8_id, u9_id])

    assert_players_received_games_with_task(
      t3_id,
      [
        {player1_topic, game_id1},
        {player2_topic, game_id2},
        {player3_topic, game_id3},
        {player4_topic, game_id4},
        {player5_topic, game_id5},
        {player6_topic, game_id6},
        {player7_topic, game_id7},
        {player8_topic, game_id8},
        {player9_topic, game_id9}
      ],
      "playing"
    )

    assert %{
             entries: [
               %{name: "u1", place: 1, score: 605, clan: "c1"},
               %{name: "u2", place: 2, score: 563, clan: "c2"},
               %{name: "u3", place: 3, score: 520, clan: "c3"},
               %{name: "u4", place: 4, score: 478, clan: "c4"},
               %{name: "u5", place: 5, score: 436, clan: "c5"},
               %{name: "u6", place: 6, score: 394, clan: "c6"},
               %{name: "u7", place: 7, score: 351, clan: "c7"},
               %{name: "u8", place: 8, score: 303, clan: "c8"},
               %{name: _, place: 9, score: 18},
               %{name: _, place: 10, score: 17}
             ]
           } = Tournament.Ranking.get_page(tournament, 1)

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    win_active_match(tournament, user1, %{opponent_percent: 33, duration_sec: 100})
    win_active_match(tournament, user2, %{opponent_percent: 33, duration_sec: 200})
    win_active_match(tournament, user3, %{opponent_percent: 33, duration_sec: 300})
    win_active_match(tournament, user4, %{opponent_percent: 33, duration_sec: 400})
    win_active_match(tournament, user5, %{opponent_percent: 33, duration_sec: 500})
    win_active_match(tournament, user6, %{opponent_percent: 33, duration_sec: 600})
    win_active_match(tournament, user7, %{opponent_percent: 33, duration_sec: 700})
    win_active_match(tournament, user8, %{opponent_percent: 33, duration_sec: 800})

    TournamentResult.upsert_results(tournament)
    Tournament.Ranking.set_ranking(tournament)
    :timer.sleep(200)

    assert_players_received_games_with_task(
      t3_id,
      [
        {player1_topic, game_id1},
        {player2_topic, game_id2},
        {player3_topic, game_id3},
        {player4_topic, game_id4},
        {player5_topic, game_id5},
        {player6_topic, game_id6},
        {player7_topic, game_id7},
        {player8_topic, game_id8}
      ],
      "game_over"
    )

    ### should be rematch with same user
    :timer.sleep(600)

    [game_id1, game_id2, game_id3, game_id4, game_id5, game_id6, game_id7, game_id8] =
      get_users_active_games([u1_id, u2_id, u3_id, u4_id, u5_id, u6_id, u7_id, u8_id])

    assert_players_received_games_with_task(
      t4_id,
      [
        {player1_topic, game_id1},
        {player2_topic, game_id2},
        {player3_topic, game_id3},
        {player4_topic, game_id4},
        {player5_topic, game_id5},
        {player6_topic, game_id6},
        {player7_topic, game_id7},
        {player8_topic, game_id8}
      ],
      "playing"
    )

    for _ <- 1..8 do
      assert_received %Message{
        topic: ^admin_topic,
        event: "tournament:updated",
        payload: %{
          tournament: %{current_round_position: 1}
        }
      }
    end

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    win_active_match(tournament, user1, %{opponent_percent: 33, duration_sec: 100})
    win_active_match(tournament, user2, %{opponent_percent: 33, duration_sec: 200})
    win_active_match(tournament, user3, %{opponent_percent: 33, duration_sec: 300})
    win_active_match(tournament, user4, %{opponent_percent: 33, duration_sec: 400})
    win_active_match(tournament, user5, %{opponent_percent: 33, duration_sec: 500})

    TournamentResult.upsert_results(tournament)
    Tournament.Ranking.set_ranking(tournament)
    :timer.sleep(200)

    assert_players_received_games_with_task(
      t4_id,
      [
        {player1_topic, game_id1},
        {player2_topic, game_id2},
        {player3_topic, game_id3},
        {player4_topic, game_id4},
        {player5_topic, game_id5}
      ],
      "game_over"
    )

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    ##### Finish 2 round
    tournament = Tournament.Context.get(tournament.id)
    assert Repo.count(TournamentResult) == 234
    Tournament.Server.finish_round_after(tournament.id, tournament.current_round_position, 0)
    :timer.sleep(600)
    assert Repo.count(TournamentResult) == 416

    assert_received %Message{
      topic: ^common_topic,
      event: "tournament:round_finished",
      payload: %{
        tournament: %{
          type: "top200",
          state: "active",
          current_round_position: 1,
          break_state: "on",
          last_round_ended_at: _,
          last_round_started_at: _,
          show_results: true
        }
      }
    }

    assert_received %Message{
      topic: ^admin_topic,
      event: "tournament:updated",
      payload: %{
        tournament: %{
          type: "top200",
          state: "active",
          current_round_position: 1,
          break_state: "on",
          last_round_ended_at: _,
          last_round_started_at: _,
          show_results: true
        }
      }
    }

    [game_id6, game_id7, game_id8, game_id9] = get_users_active_games([u6_id, u7_id, u8_id, u9_id])

    assert_players_received_games_with_task(
      t4_id,
      [
        {player6_topic, game_id6},
        {player7_topic, game_id7},
        {player8_topic, game_id8}
      ],
      "timeout"
    )

    assert_players_received_games_with_task(
      t3_id,
      [
        {player9_topic, game_id9}
      ],
      "timeout"
    )

    assert_received %Message{
      topic: ^admin_topic,
      event: "tournament:updated",
      payload: %{
        tournament: %{
          type: "top200",
          state: "active",
          current_round_position: 1,
          break_state: "on",
          last_round_ended_at: _,
          last_round_started_at: _,
          show_results: true
        }
      }
    }

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    assert %{
             "current_round" => 2,
             "players" => players,
             "tournament_id" => ^t_id
           } = Tournament.Helpers.get_player_ranking_stats(tournament)

    {active, bottom} = Enum.split_with(players, &(&1["active"] == 1))
    assert Enum.count(active) == 64
    assert Enum.count(bottom) == 128

    ##### Start 3 round
    tournament = Tournament.Context.get(tournament.id)
    Tournament.Server.stop_round_break_after(tournament.id, tournament.current_round_position, 0)
    :timer.sleep(300)
    assert_total_playing_matches(tournament, 96)

    assert_received %Message{
      topic: ^common_topic,
      event: "tournament:round_created",
      payload: %{
        tournament: %{
          state: "active",
          current_round_position: 2,
          break_state: "off",
          last_round_ended_at: _,
          last_round_started_at: _
        }
      }
    }

    assert_received %Message{
      topic: ^admin_topic,
      event: "tournament:updated",
      payload: %{
        tournament: %{
          state: "active",
          current_round_position: 2,
          break_state: "off",
          last_round_ended_at: _,
          last_round_started_at: _
        }
      }
    }

    [game_id1, game_id2, game_id3, game_id4, game_id5, game_id6, game_id7, game_id8, game_id9] =
      get_users_active_games([u1_id, u2_id, u3_id, u4_id, u5_id, u6_id, u7_id, u8_id, u9_id])

    assert_players_received_games_with_task(
      t5_id,
      [
        {player1_topic, game_id1},
        {player2_topic, game_id2},
        {player3_topic, game_id3},
        {player4_topic, game_id4},
        {player5_topic, game_id5},
        {player6_topic, game_id6},
        {player7_topic, game_id7},
        {player8_topic, game_id8},
        {player9_topic, game_id9}
      ],
      "playing"
    )

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    ##### Round 3 - Win matches
    tournament = Tournament.Context.get(tournament.id)
    win_active_match(tournament, user1, %{opponent_percent: 33, duration_sec: 100})
    win_active_match(tournament, user2, %{opponent_percent: 33, duration_sec: 200})
    win_active_match(tournament, user3, %{opponent_percent: 33, duration_sec: 300})
    win_active_match(tournament, user4, %{opponent_percent: 33, duration_sec: 400})
    win_active_match(tournament, user5, %{opponent_percent: 33, duration_sec: 500})

    :timer.sleep(600)
    TournamentResult.upsert_results(tournament)
    Tournament.Ranking.set_ranking(tournament)
    :timer.sleep(600)

    assert %{
             entries: [
               %{name: "u1", place: 1, score: 1955, clan: "c1"},
               %{name: "u2", place: 2, score: 1774, clan: "c2"},
               %{name: "u3", place: 3, score: 1591, clan: "c3"},
               %{name: "u4", place: 4, score: 1410, clan: "c4"},
               %{name: "u5", place: 5, score: 1229, clan: "c5"},
               %{name: "u6", place: 6, score: 748, clan: "c6"},
               %{name: "u7", place: 7, score: 665, clan: "c7"},
               %{name: "u8", place: 8, score: 578, clan: "c8"},
               _,
               _
             ]
           } = Tournament.Ranking.get_page(tournament, 1)

    assert_players_received_games_with_task(
      t5_id,
      [
        {player1_topic, game_id1},
        {player2_topic, game_id2},
        {player3_topic, game_id3},
        {player4_topic, game_id4},
        {player5_topic, game_id5}
      ],
      "game_over"
    )

    [game_id1, game_id2, game_id3, game_id4, game_id5, game_id6, game_id7, game_id8, game_id9] =
      get_users_active_games([u1_id, u2_id, u3_id, u4_id, u5_id, u6_id, u7_id, u8_id, u9_id])

    assert_players_received_games_with_task(
      t6_id,
      [
        {player1_topic, game_id1},
        {player2_topic, game_id2},
        {player3_topic, game_id3},
        {player4_topic, game_id4},
        {player5_topic, game_id5}
      ],
      "playing"
    )

    for _ <- 1..5 do
      assert_received %Message{
        topic: ^admin_topic,
        event: "tournament:updated",
        payload: %{
          tournament: %{current_round_position: 2}
        }
      }
    end

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    ##### Finish 3 round
    assert Repo.count(TournamentResult) == 426
    Tournament.Server.finish_round_after(tournament.id, tournament.current_round_position, 0)
    :timer.sleep(600)
    assert Repo.count(TournamentResult) == 618

    assert_received %Message{
      topic: ^common_topic,
      event: "tournament:round_finished",
      payload: %{
        tournament: %{
          type: "top200",
          state: "active",
          current_round_position: 2,
          break_state: "on",
          last_round_ended_at: _,
          last_round_started_at: _,
          show_results: true
        }
      }
    }

    assert_received %Message{
      topic: ^admin_topic,
      event: "tournament:updated",
      payload: %{
        tournament: %{
          type: "top200",
          state: "active",
          current_round_position: 2,
          break_state: "on",
          last_round_ended_at: _,
          last_round_started_at: _,
          show_results: true
        }
      }
    }

    assert_players_received_games_with_task(
      t6_id,
      [
        {player1_topic, game_id1},
        {player2_topic, game_id2},
        {player3_topic, game_id3},
        {player4_topic, game_id4},
        {player5_topic, game_id5}
      ],
      "timeout"
    )

    assert_players_received_games_with_task(
      t5_id,
      [
        {player6_topic, game_id6},
        {player7_topic, game_id7},
        {player8_topic, game_id8},
        {player9_topic, game_id9}
      ],
      "timeout"
    )

    assert_received %Message{
      topic: ^admin_topic,
      event: "tournament:updated",
      payload: %{
        tournament: %{
          type: "top200",
          state: "active",
          current_round_position: 2,
          break_state: "on",
          last_round_ended_at: _,
          last_round_started_at: _,
          show_results: true
        }
      }
    }

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    assert %{
             "current_round" => 3,
             "players" => players,
             "tournament_id" => ^t_id
           } = Tournament.Helpers.get_player_ranking_stats(tournament)

    {active, bottom} = Enum.split_with(players, &(&1["active"] == 1))
    assert Enum.count(active) == 32
    assert Enum.count(bottom) == 160

    ##### Start 4 round
    tournament = Tournament.Context.get(tournament.id)
    Tournament.Server.stop_round_break_after(tournament.id, tournament.current_round_position, 0)
    :timer.sleep(300)
    assert_total_playing_matches(tournament, 96)

    assert_received %Message{
      topic: ^common_topic,
      event: "tournament:round_created",
      payload: %{
        tournament: %{
          state: "active",
          current_round_position: 3,
          break_state: "off",
          last_round_ended_at: _,
          last_round_started_at: _
        }
      }
    }

    assert_received %Message{
      topic: ^admin_topic,
      event: "tournament:updated",
      payload: %{
        tournament: %{
          type: "top200",
          state: "active",
          current_round_position: 3,
          break_state: "off",
          last_round_ended_at: _,
          last_round_started_at: _,
          show_results: true
        }
      }
    }

    [game_id1, game_id2, game_id3, game_id4, game_id5, game_id6, game_id7, game_id8, game_id9] =
      get_users_active_games([u1_id, u2_id, u3_id, u4_id, u5_id, u6_id, u7_id, u8_id, u9_id])

    assert_players_received_games_with_task(
      t7_id,
      [
        {player1_topic, game_id1},
        {player2_topic, game_id2},
        {player3_topic, game_id3},
        {player4_topic, game_id4},
        {player5_topic, game_id5},
        {player6_topic, game_id6},
        {player7_topic, game_id7},
        {player8_topic, game_id8},
        {player9_topic, game_id9}
      ],
      "playing"
    )

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    win_active_match(tournament, user1, %{opponent_percent: 0, duration_sec: 2000})
    # Underdog run
    win_active_match(tournament, user9, %{opponent_percent: 0, duration_sec: 1})

    :timer.sleep(600)
    TournamentResult.upsert_results(tournament)
    Tournament.Ranking.set_ranking(tournament)
    :timer.sleep(300)

    assert %{
             entries: [
               %{name: "u1", place: 1, score: 2456},
               %{name: "u2", place: 2, score: 1774},
               %{name: "u3", place: 3, score: 1591},
               %{name: "u4", place: 4, score: 1410},
               %{name: "u5", place: 5, score: 1229},
               %{name: "u9", place: 6, score: 1002},
               %{name: "u6", place: 7, score: 748},
               %{name: "u7", place: 8, score: 665},
               %{name: "u8", place: 9, score: 578},
               _
             ]
           } = Tournament.Ranking.get_page(tournament, 1)

    assert_players_received_games_with_task(t7_id, [{player1_topic, game_id1}, {player9_topic, game_id9}], "game_over")

    [game_id1, game_id9] = get_users_active_games([u1_id, u9_id])

    assert_players_received_games_with_task(
      t8_id,
      [
        {player1_topic, game_id1},
        {player9_topic, game_id9}
      ],
      "playing"
    )

    for _ <- 1..2 do
      assert_received %Message{
        topic: ^admin_topic,
        event: "tournament:updated",
        payload: %{
          tournament: %{
            type: "top200",
            state: "active",
            current_round_position: 3,
            break_state: "off",
            last_round_ended_at: _,
            last_round_started_at: _,
            show_results: true
          }
        }
      }
    end

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    ##### Finish 4 round
    tournament = Tournament.Context.get(tournament.id)
    assert Repo.count(TournamentResult) == 622
    Tournament.Server.finish_round_after(tournament.id, tournament.current_round_position, 0)
    :timer.sleep(800)
    assert Repo.count(TournamentResult) == 814

    assert_players_received_games_with_task(
      t7_id,
      [
        {player2_topic, game_id2},
        {player3_topic, game_id3},
        {player4_topic, game_id4},
        {player5_topic, game_id5},
        {player6_topic, game_id6},
        {player7_topic, game_id7},
        {player8_topic, game_id8}
      ],
      "timeout"
    )

    assert_players_received_games_with_task(
      t8_id,
      [
        {player1_topic, game_id1},
        {player9_topic, game_id9}
      ],
      "timeout"
    )

    assert_received %Message{
      topic: ^common_topic,
      event: "tournament:round_finished",
      payload: %{
        tournament: %{
          type: "top200",
          state: "active",
          current_round_position: 3,
          break_state: "on",
          last_round_ended_at: _,
          last_round_started_at: _,
          show_results: true
        }
      }
    }

    assert_received %Message{
      topic: ^admin_topic,
      event: "tournament:updated",
      payload: %{
        tournament: %{
          type: "top200",
          state: "active",
          current_round_position: 3,
          break_state: "on",
          last_round_ended_at: _,
          last_round_started_at: _,
          show_results: true
        }
      }
    }

    assert_received %Message{
      topic: ^admin_topic,
      event: "tournament:updated",
      payload: %{
        tournament: %{
          type: "top200",
          state: "active",
          current_round_position: 3,
          break_state: "on",
          last_round_ended_at: _,
          last_round_started_at: _,
          show_results: true
        }
      }
    }

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    assert %{
             "current_round" => 4,
             "players" => [p1, p2, p3, p4, p5, p6, p7, p8, p9, p10 | _] = players,
             "tournament_id" => ^t_id
           } = Tournament.Helpers.get_player_ranking_stats(tournament)

    assert 2 == Enum.count(players, &(&1["returned"] == 1))

    {active, bottom} = Enum.split_with(players, &(&1["active"] == 1))
    assert Enum.count(active) == 8
    assert Enum.count(bottom) == 184

    assert %{
             "active" => 1,
             "clan_id" => _,
             "history" => [
               %{round: 4, score: 501, player_win_status: true, solved_tasks: ["won", "timeout"]},
               %{round: 3, score: 400, player_win_status: true, solved_tasks: ["won", "timeout"]},
               %{round: 2, score: 950, player_win_status: true, solved_tasks: ["won", "won"]},
               %{round: 1, score: 605, player_win_status: true, solved_tasks: ["won", "won"]}
             ],
             "id" => _,
             "name" => "u1",
             "rank" => 1,
             "returned" => 0,
             "total_score" => 2456,
             "total_tasks" => 8,
             "win_prob" => "42",
             "won_tasks" => 6
           } = p1

    assert %{
             "active" => 1,
             "clan_id" => _,
             "history" => [
               %{round: 4, score: 0, player_win_status: true, solved_tasks: ["timeout"]},
               %{round: 3, score: 350, player_win_status: true, solved_tasks: ["won", "timeout"]},
               %{round: 2, score: 861, player_win_status: true, solved_tasks: ["won", "won"]},
               %{round: 1, score: 563, player_win_status: true, solved_tasks: ["won", "won"]}
             ],
             "id" => _,
             "name" => "u2",
             "rank" => 2,
             "returned" => 0,
             "total_score" => 1774,
             "total_tasks" => 7,
             "win_prob" => _,
             "won_tasks" => 5
           } = p2

    assert %{
             "active" => 1,
             "rank" => 3,
             "total_score" => 1591,
             "history" => [
               %{round: 4, score: 0, player_win_status: true, solved_tasks: ["timeout"]},
               %{round: 3, score: 300, player_win_status: true, solved_tasks: ["won", "timeout"]},
               %{round: 2, score: 771, player_win_status: true, solved_tasks: ["won", "won"]},
               %{round: 1, score: 520, player_win_status: true, solved_tasks: ["won", "won"]}
             ],
             "win_prob" => _,
             "total_tasks" => 7,
             "won_tasks" => 5
           } = p3

    assert %{
             "active" => 1,
             "rank" => 4,
             "total_score" => 1410,
             "history" => [
               %{round: 4, score: 0, player_win_status: true, solved_tasks: ["timeout"]},
               %{round: 3, score: 250, player_win_status: true, solved_tasks: ["won", "timeout"]},
               %{round: 2, score: 682, player_win_status: true, solved_tasks: ["won", "won"]},
               %{round: 1, score: 478, player_win_status: true, solved_tasks: ["won", "won"]}
             ],
             "name" => "u4",
             "returned" => 0,
             "total_tasks" => 7,
             "win_prob" => "42",
             "won_tasks" => 5
           } = p4

    assert %{
             "active" => 1,
             "rank" => 5,
             "total_score" => 1229,
             "history" => [
               %{round: 4, score: 0, player_win_status: true, solved_tasks: ["timeout"]},
               %{round: 3, score: 200, player_win_status: true, solved_tasks: ["won", "timeout"]},
               %{round: 2, score: 593, player_win_status: true, solved_tasks: ["won", "won"]},
               %{round: 1, score: 436, player_win_status: true, solved_tasks: ["won", "won"]}
             ],
             "name" => "u5",
             "returned" => 0,
             "total_tasks" => 7,
             "win_prob" => "42",
             "won_tasks" => 5
           } = p5

    assert %{
             "active" => 1,
             "rank" => 6,
             "history" => [
               %{player_win_status: true, round: 4, score: 1002, solved_tasks: ["won", "timeout"]},
               %{player_win_status: false, round: 3, score: 0, solved_tasks: ["timeout"]},
               %{player_win_status: false, round: 2, score: 0, solved_tasks: ["timeout"]},
               %{player_win_status: false, round: 1, score: 0, solved_tasks: ["timeout"]}
             ],
             "name" => "u9",
             "returned" => 1,
             "total_score" => 1002,
             "total_tasks" => 5,
             "win_prob" => "42",
             "won_tasks" => 1
           } = p6

    assert %{
             "active" => 1,
             "rank" => 7,
             "total_score" => 748,
             "history" => [
               %{round: 4, score: 0, player_win_status: true, solved_tasks: ["timeout"]},
               %{round: 3, score: 0, player_win_status: true, solved_tasks: ["timeout"]},
               %{round: 2, score: 354, player_win_status: true, solved_tasks: ["won", "timeout"]},
               %{round: 1, score: 394, player_win_status: true, solved_tasks: ["won", "won"]}
             ],
             "name" => "u6",
             "returned" => 0,
             "total_tasks" => 6,
             "win_prob" => "42",
             "won_tasks" => 3
           } = p7

    assert %{
             "active" => 1,
             "rank" => 8,
             "total_score" => 665,
             "history" => [
               %{round: 4, score: 0, player_win_status: true, solved_tasks: ["timeout"]},
               %{round: 3, score: 0, player_win_status: true, solved_tasks: ["timeout"]},
               %{round: 2, score: 314, player_win_status: true, solved_tasks: ["won", "timeout"]},
               %{round: 1, score: 351, player_win_status: true, solved_tasks: ["won", "won"]}
             ],
             "name" => "u7",
             "returned" => 1,
             "total_tasks" => 6,
             "win_prob" => "42",
             "won_tasks" => 3
           } = p8

    assert %{
             "active" => 0,
             "rank" => 9,
             "history" => [],
             "total_score" => 578,
             "name" => "u8",
             "returned" => 0,
             "total_tasks" => 6,
             "win_prob" => "42",
             "won_tasks" => 3
           } = p9

    assert %{"active" => 0, "rank" => 10, "history" => [], "won_tasks" => 0} = p10

    ##### Start 5 round
    tournament = Tournament.Context.get(tournament.id)
    Tournament.Server.stop_round_break_after(tournament.id, tournament.current_round_position, 0)
    :timer.sleep(300)
    assert_total_playing_matches(tournament, 96)

    assert_received %Message{
      topic: ^common_topic,
      event: "tournament:round_created",
      payload: %{
        tournament: %{
          state: "active",
          current_round_position: 4,
          break_state: "off",
          last_round_ended_at: _,
          last_round_started_at: _
        }
      }
    }

    assert_received %Message{
      topic: ^admin_topic,
      event: "tournament:updated",
      payload: %{
        tournament: %{
          state: "active",
          current_round_position: 4,
          break_state: "off",
          last_round_ended_at: _,
          last_round_started_at: _
        }
      }
    }

    [game_id1, game_id2, game_id3, game_id4, game_id5, game_id6, game_id7, game_id8, game_id9] =
      get_users_active_games([u1_id, u2_id, u3_id, u4_id, u5_id, u6_id, u7_id, u8_id, u9_id])

    assert_players_received_games_with_task(
      t9_id,
      [
        {player1_topic, game_id1},
        {player2_topic, game_id2},
        {player3_topic, game_id3},
        {player4_topic, game_id4},
        {player5_topic, game_id5},
        {player6_topic, game_id6},
        {player7_topic, game_id7},
        {player8_topic, game_id8},
        {player9_topic, game_id9}
      ],
      "playing"
    )

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    ##### Round 5 - Win matches
    tournament = Tournament.Context.get(tournament.id)
    win_active_match(tournament, user1, %{opponent_percent: 0, duration_sec: 100})

    :timer.sleep(300)
    assert_players_received_games_with_task(t9_id, [{player1_topic, game_id1}], "game_over")

    assert_received %Message{
      topic: ^admin_topic,
      event: "tournament:updated",
      payload: %{
        tournament: %{current_round_position: 4}
      }
    }

    :timer.sleep(100)
    TournamentResult.upsert_results(tournament)
    Tournament.Ranking.set_ranking(tournament)
    :timer.sleep(100)

    assert %{
             entries: [
               %{name: "u1", place: 1, score: 2656},
               %{name: "u2", place: 2, score: 1774},
               %{name: "u3", place: 3, score: 1591},
               %{name: "u4", place: 4, score: 1410},
               %{name: "u5", place: 5, score: 1229},
               %{name: "u9", score: 1002, place: 6},
               %{name: "u6", score: 748, place: 7},
               %{name: "u7", score: 665, place: 8},
               %{name: "u8", score: 578, place: 9},
               _
             ]
           } = Tournament.Ranking.get_page(tournament, 1)

    # cause we don't know which players plays with which one
    # Flush the process mailbox
    receive do
      _ -> flush_messages()
    after
      0 -> :ok
    end

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    ##### Finish 5 round
    Tournament.Server.finish_round_after(tournament.id, tournament.current_round_position, 0)
    :timer.sleep(600)

    assert_received %Message{
      topic: ^common_topic,
      event: "tournament:round_finished",
      payload: %{
        tournament: %{
          type: "top200",
          state: "active",
          current_round_position: 4,
          break_state: "on",
          last_round_ended_at: _,
          last_round_started_at: _,
          show_results: true
        }
      }
    }

    [game_id1] = get_users_active_games([u1_id])

    assert_players_received_games_with_task(
      t10_id,
      [
        {player1_topic, game_id1}
      ],
      "timeout"
    )

    for _ <- 1..2 do
      assert_received %Message{
        topic: _,
        event: "tournament:updated",
        payload: %{
          tournament: %{
            state: "active",
            current_round_position: 4,
            break_state: "on",
            last_round_ended_at: _,
            last_round_started_at: _
          }
        }
      }
    end

    for _ <- 1..8 do
      assert_received %Message{
        topic: _,
        event: "tournament:match:upserted",
        payload: %{match: %{task_id: _, state: "timeout"}}
      }
    end

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    assert %{
             "current_round" => 5,
             "players" => [p1 | _] = players,
             "tournament_id" => ^t_id
           } = Tournament.Helpers.get_player_ranking_stats(tournament)

    assert 0 == Enum.count(players, &(&1["returned"] == 1))

    {active, bottom} = Enum.split_with(players, &(&1["active"] == 1))
    assert Enum.count(active) == 4
    assert Enum.count(bottom) == 188

    assert %{
             "active" => 1,
             "clan_id" => _,
             "history" => [
               %{round: 5, score: 200, player_win_status: true, solved_tasks: ["won", "timeout"]},
               %{round: 4, score: 501, player_win_status: true, solved_tasks: ["won", "timeout"]},
               %{round: 3, score: 400, player_win_status: true, solved_tasks: ["won", "timeout"]},
               %{round: 2, score: 950, player_win_status: true, solved_tasks: ["won", "won"]},
               %{round: 1, score: 605, player_win_status: true, solved_tasks: ["won", "won"]}
             ],
             "id" => _,
             "name" => "u1",
             "rank" => 1,
             "returned" => 0,
             "total_score" => 2656,
             "total_tasks" => 10,
             "win_prob" => "42",
             "won_tasks" => 7
           } = p1

    ##### Start 6 round
    tournament = Tournament.Context.get(tournament.id)
    Tournament.Server.stop_round_break_after(tournament.id, tournament.current_round_position, 0)
    :timer.sleep(600)
    assert_total_playing_matches(tournament, 96)

    assert_received %Message{
      topic: ^common_topic,
      event: "tournament:round_created",
      payload: %{
        tournament: %{
          state: "active",
          current_round_position: 5,
          break_state: "off",
          last_round_ended_at: _,
          last_round_started_at: _
        }
      }
    }

    assert_received %Message{
      topic: ^admin_topic,
      event: "tournament:updated",
      payload: %{
        tournament: %{
          state: "active",
          current_round_position: 5,
          break_state: "off",
          last_round_ended_at: _,
          last_round_started_at: _
        }
      }
    }

    [game_id1, game_id2, game_id3, game_id4, game_id5, game_id6, game_id7, game_id8, game_id9] =
      get_users_active_games([u1_id, u2_id, u3_id, u4_id, u5_id, u6_id, u7_id, u8_id, u9_id])

    assert_players_received_games_with_task(
      t11_id,
      [
        {player1_topic, game_id1},
        {player2_topic, game_id2},
        {player3_topic, game_id3},
        {player4_topic, game_id4},
        {player5_topic, game_id5},
        {player6_topic, game_id6},
        {player7_topic, game_id7},
        {player8_topic, game_id8},
        {player9_topic, game_id9}
      ],
      "playing"
    )

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    ##### Round 6 - Win matches
    tournament = Tournament.Context.get(tournament.id)
    win_active_match(tournament, user1, %{opponent_percent: 0, duration_sec: 100})

    :timer.sleep(200)
    TournamentResult.upsert_results(tournament)
    Tournament.Ranking.set_ranking(tournament)
    :timer.sleep(400)

    assert_received %Message{
      topic: ^admin_topic,
      event: "tournament:updated",
      payload: %{
        tournament: %{current_round_position: 5}
      }
    }

    for _ <- 1..2 do
      assert_received %Message{
        topic: _,
        event: "tournament:match:upserted",
        payload: %{match: %{task_id: ^t11_id, state: "game_over"}}
      }

      assert_received %Message{
        topic: _,
        event: "tournament:match:upserted",
        payload: %{match: %{task_id: ^t12_id, state: "playing"}}
      }
    end

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    ##### Finish 6 round
    Tournament.Server.finish_round_after(tournament.id, tournament.current_round_position, 0)
    :timer.sleep(600)

    assert_received %Message{
      topic: ^common_topic,
      event: "tournament:round_finished",
      payload: %{
        tournament: %{
          type: "top200",
          state: "active",
          current_round_position: 5,
          break_state: "on",
          last_round_ended_at: _,
          last_round_started_at: _,
          show_results: true
        }
      }
    }

    for _ <- 1..2 do
      assert_received %Message{
        topic: ^admin_topic,
        event: "tournament:updated",
        payload: %{
          tournament: %{
            type: "top200",
            state: "active",
            current_round_position: 5,
            break_state: "on",
            last_round_ended_at: _,
            last_round_started_at: _,
            show_results: true
          }
        }
      }
    end

    for _ <- 1..7 do
      assert_received %Message{
        topic: _,
        event: "tournament:match:upserted",
        payload: %{match: %{task_id: ^t11_id, state: "timeout"}}
      }
    end

    for _ <- 1..2 do
      assert_received %Message{
        topic: _,
        event: "tournament:match:upserted",
        payload: %{match: %{task_id: ^t12_id, state: "timeout"}}
      }
    end

    TournamentResult.upsert_results(tournament)
    Tournament.Ranking.set_ranking(tournament)
    :timer.sleep(400)

    assert %{
             entries: [
               %{place: 1, score: 2856, name: "u1"} | _
             ]
           } = Tournament.Ranking.get_page(tournament, 1)

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    assert %{
             "current_round" => 6,
             "players" => [p1 | _] = players,
             "tournament_id" => ^t_id
           } = Tournament.Helpers.get_player_ranking_stats(tournament)

    {active, bottom} = Enum.split_with(players, &(&1["active"] == 1))
    assert Enum.count(active) == 2
    assert Enum.count(bottom) == 190

    assert %{
             "active" => 1,
             "clan_id" => _,
             "history" => [
               %{round: 6, score: 200, player_win_status: true, solved_tasks: ["won", "timeout"]},
               %{round: 5, score: 200, player_win_status: true, solved_tasks: ["won", "timeout"]},
               %{round: 4, score: 501, player_win_status: true, solved_tasks: ["won", "timeout"]},
               %{round: 3, score: 400, player_win_status: true, solved_tasks: ["won", "timeout"]},
               %{round: 2, score: 950, player_win_status: true, solved_tasks: ["won", "won"]},
               %{round: 1, score: 605, player_win_status: true, solved_tasks: ["won", "won"]}
             ],
             "id" => _,
             "name" => "u1",
             "rank" => 1,
             "returned" => 0,
             "total_score" => 2856,
             "total_tasks" => 12,
             "win_prob" => "42",
             "won_tasks" => 8
           } = p1

    ##### Start 7 round
    tournament = Tournament.Context.get(tournament.id)
    Tournament.Server.stop_round_break_after(tournament.id, tournament.current_round_position, 0)
    :timer.sleep(600)

    assert_received %Message{
      topic: ^common_topic,
      event: "tournament:round_created",
      payload: %{
        tournament: %{
          state: "active",
          current_round_position: 6,
          break_state: "off",
          last_round_ended_at: _,
          last_round_started_at: _
        }
      }
    }

    assert_received %Message{
      topic: ^admin_topic,
      event: "tournament:updated",
      payload: %{
        tournament: %{
          state: "active",
          current_round_position: 6,
          break_state: "off",
          last_round_ended_at: _,
          last_round_started_at: _
        }
      }
    }

    [game_id1, game_id2, game_id3, game_id4, game_id5, game_id6, game_id7, game_id8, game_id9] =
      get_users_active_games([u1_id, u2_id, u3_id, u4_id, u5_id, u6_id, u7_id, u8_id, u9_id])

    assert_players_received_games_with_task(
      t13_id,
      [
        {player1_topic, game_id1},
        {player2_topic, game_id2},
        {player3_topic, game_id3},
        {player4_topic, game_id4},
        {player5_topic, game_id5},
        {player6_topic, game_id6},
        {player7_topic, game_id7},
        {player8_topic, game_id8},
        {player9_topic, game_id9}
      ],
      "playing"
    )

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    ##### Round 7 - Win matches
    tournament = Tournament.Context.get(tournament.id)
    [game_id1] = get_users_active_games([u1_id])

    win_active_match(tournament, user1, %{opponent_percent: 33, duration_sec: 100})
    :timer.sleep(300)

    assert_received %Message{
      topic: ^admin_topic,
      event: "tournament:updated",
      payload: %{
        tournament: %{
          type: "top200",
          state: "active",
          current_round_position: 6,
          break_state: "off",
          last_round_ended_at: _,
          last_round_started_at: _,
          show_results: true
        }
      }
    }

    assert_players_received_games_with_task(t13_id, [{player1_topic, game_id1}], "game_over")

    [game_id2] = get_users_active_games([u1_id])
    assert_players_received_games_with_task(t14_id, [{player1_topic, game_id2}], "playing")

    assert_received %Message{
      topic: opponent_topic,
      event: "tournament:match:upserted",
      payload: %{
        match: %{task_id: ^t13_id, state: "game_over", game_id: ^game_id1}
      }
    }

    assert_received %Message{
      topic: ^opponent_topic,
      event: "tournament:match:upserted",
      payload: %{
        match: %{task_id: ^t14_id, state: "playing", game_id: ^game_id2}
      }
    }

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    win_active_match(tournament, user1, %{opponent_percent: 33, duration_sec: 100})
    :timer.sleep(300)

    assert_players_received_games_with_task(
      t14_id,
      [{player1_topic, game_id2}, {opponent_topic, game_id2}],
      "game_over"
    )

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    :timer.sleep(100)
    TournamentResult.upsert_results(tournament)
    Tournament.Ranking.set_ranking(tournament)
    :timer.sleep(100)

    # Verify final tournament ranking
    assert %{
             entries: [%{place: 1, score: 3256, name: "u1"} | _]
           } = Tournament.Ranking.get_page(tournament, 1)

    ##### Finish 7 round - Tournament should be completed
    Tournament.Server.finish_round_after(tournament.id, tournament.current_round_position, 0)
    :timer.sleep(600)

    assert_received %Message{
      topic: ^common_topic,
      event: "tournament:round_finished",
      payload: %{
        tournament: %{
          type: "top200",
          state: "active",
          current_round_position: 6,
          break_state: "on",
          last_round_ended_at: _,
          last_round_started_at: _,
          show_results: true
        }
      }
    }

    for _ <- 1..7 do
      assert_received %Message{
        topic: _,
        event: "tournament:match:upserted",
        payload: %{
          match: %{state: "timeout"}
        }
      }
    end

    assert_received %Message{
      topic: ^admin_topic,
      event: "tournament:updated",
      payload: %{
        tournament: %{
          type: "top200",
          state: "active",
          current_round_position: 6,
          break_state: "on",
          last_round_ended_at: _,
          last_round_started_at: _,
          show_results: true
        }
      }
    }

    assert_received %Message{
      topic: ^admin_topic,
      event: "tournament:updated",
      payload: %{
        tournament: %{
          type: "top200",
          state: "finished",
          current_round_position: 6,
          break_state: "off",
          last_round_ended_at: _,
          last_round_started_at: _,
          show_results: true
        }
      }
    }

    assert_received %Message{
      topic: ^common_topic,
      event: "tournament:finished",
      payload: %{
        tournament: %{
          type: "top200",
          state: "finished",
          current_round_position: 6,
          break_state: "off",
          last_round_ended_at: _,
          last_round_started_at: _,
          show_results: true
        }
      }
    }

    assert Process.info(self(), :message_queue_len) == {:message_queue_len, 0}

    # Verify tournament is in finished state
    tournament = Tournament.Context.get(tournament.id)
    assert tournament.state == "finished"
    assert tournament.current_round_position == 6

    # Verify final rankings are correct
    final_ranking = Tournament.Ranking.get_page(tournament, 1)
    assert %{place: 1, score: 3256, name: "u1"} = Enum.at(final_ranking.entries, 0)

    # Verify all matches are completed
    assert Enum.empty?(Tournament.Helpers.get_matches(tournament, "playing"))

    # Verify tournament results for all players
    assert Repo.count(TournamentResult) == 1396

    assert %{
             "current_round" => 7,
             "players" => [p1 | _] = players,
             "tournament_id" => ^t_id
           } = Tournament.Helpers.get_player_ranking_stats(tournament)

    {active, bottom} = Enum.split_with(players, &(&1["active"] == 1))
    assert Enum.count(active) == 1
    assert Enum.count(bottom) == 191

    assert %{
             "active" => 1,
             "clan_id" => _,
             "history" => [
               %{round: 7, score: 400, player_win_status: true, solved_tasks: ["won", "won"]},
               %{round: 6, score: 200, player_win_status: true, solved_tasks: ["won", "timeout"]},
               %{round: 5, score: 200, player_win_status: true, solved_tasks: ["won", "timeout"]},
               %{round: 4, score: 501, player_win_status: true, solved_tasks: ["won", "timeout"]},
               %{round: 3, score: 400, player_win_status: true, solved_tasks: ["won", "timeout"]},
               %{round: 2, score: 950, player_win_status: true, solved_tasks: ["won", "won"]},
               %{round: 1, score: 605, player_win_status: true, solved_tasks: ["won", "won"]}
             ],
             "id" => _,
             "name" => "u1",
             "rank" => 1,
             "returned" => 0,
             "total_score" => 3256,
             "total_tasks" => 14,
             "win_prob" => "42",
             "won_tasks" => 10
           } = p1
  end

  defp get_users_active_games(user_ids) do
    games = Game |> Repo.all() |> Enum.sort_by(& &1.id, :desc)

    Enum.map(user_ids, fn user_id ->
      games |> Enum.find(&Enum.member?(&1.player_ids, user_id)) |> Map.get(:id)
    end)
  end

  defp assert_players_received_games_with_task(task_id, games, state) do
    Enum.each(games, fn {topic, game_id} ->
      assert_received %Message{
        topic: ^topic,
        event: "tournament:match:upserted",
        payload: %{match: %{game_id: ^game_id, task_id: ^task_id, state: ^state}}
      }
    end)
  end

  # Helper to verify the number of matches in playing state
  defp assert_total_playing_matches(tournament, count) do
    matches = Tournament.Helpers.get_matches(tournament, "playing")
    assert Enum.count(matches) == count
  end

  # Helper function to flush all messages in the process mailbox
  defp flush_messages do
    receive do
      _ -> flush_messages()
    after
      0 -> :ok
    end
  end
end
