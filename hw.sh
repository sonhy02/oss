#!/bin/bash

# 파일 존재 여부 확인
for file in "$1" "$2" "$3"; do
    if ! [ -f "$file" ]; then
        echo "에러: $file 파일을 찾을 수 없습니다."
        exit 1
    fi
done

# 시작 메시지 출력
echo "************OSS1 - Project1************"
echo "* StudentID : 12234135 *"
echo "* Name : SON HOYOUNG *"
echo "******************************************"

# 메뉴 표시 및 선택
while true; do
    echo "[MENU]"
    options=("Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in players.csv"
             "Get the team data to enter a league position in teams.csv"
             "Get the Top-3 Attendance matches in matches.csv"
             "Get each team's ranking and the highest-scoring player"
             "Get the modified format of date_GMT in matches.csv"
             "Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
             "Exit")
    select opt in "${options[@]}"; do
        case $REPLY in
            1)
                player_name="Heung-Min Son"
                csv_file="players.csv"
                read -p "Do you want to get the Heung-Min Son's data? (y/n) :" temp;
                if [ "$temp" = "y" ]; then
                    while IFS=, read -r full_name age position current_club nationality appearances goals assists; do
                        if [ "$full_name" = "$player_name" ]; then
                            echo "Team: $current_club, Appearance: $appearances, Goal: $goals, Assist: $assists"
                        fi
                    done < "$csv_file"
                fi
                ;;
            2)
                read -p "Enter league position [1~20]: " league_position
                csv_file="teams.csv"
                while IFS=, read -r common_name wins draws losses points_per_game team_league_position cards_total shots fouls; do
                    if [ "$league_position" -eq "$team_league_position" ]; then
                        points_per_game=$(echo "scale=6; $wins / ($wins + $draws + $losses)" | bc)
                        echo "$team_league_position $common_name $points_per_game"
                        break
                    fi
                done < "$csv_file"
                ;;
            3)
                csv_file="matches.csv"
                read -p "Do you want to know Top-3 attendance data and average attendance? (y/n) : " choice
                if [ "$choice" = "y" ]; then
                    echo "***Top-3 Attendance Match***"
                    sort -t',' -rk2,2 -n "$csv_file" | head -n 3 | while IFS=, read -r date_GMT attendance home_team_name away_team_name home_team_goal_count away_team_goal_count stadium_name; do
                        echo "$home_team_name vs $away_team_name ($date_GMT)"
                        echo "$attendance $stadium_name"
                        echo "----------------------"
                    done
                    average_attendance=$(awk -F ',' '{sum+=$2} END {print "Average Attendance: " sum/NR}' "$csv_file")
                    echo "$average_attendance"
                fi
                ;;
            4)
                read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n) : " choice
                if [ "$choice" = "y" ]; then
                    # 팀의 리그 포지션과 최고 득점자 찾기
                    csv_teams="teams.csv"
                    csv_players="players.csv"

                    while IFS=, read -r common_name wins draws losses points_per_game team_league_position cards_total shots fouls; do
                        echo "$team_league_position $common_name"
                        highest_scorer=""
                        highest_score=0

                        while IFS=, read -r full_name age position current_club nationality appearances goals assists; do
                            if [ "$current_club" = "$common_name" ] && [ "$goals" -gt "$highest_score" ]; then
                                highest_scorer="$full_name"
                                highest_score="$goals"
                            fi
                        done < <(sort -t',' -nk1,1 "$csv_players")

                        echo "$highest_scorer $highest_score"
                        echo "----------------------"
                    done < <(sort -t',' -nk1,1 "$csv_teams")
                fi
                ;;
            5) echo "Option 5 selected"; break ;;
            6) echo "Option 6 selected"; break ;;
            7) echo "Exiting..."; exit ;;
            *) echo "Invalid option. Please select a number between 1 and 7.";;
        esac
    done
done
