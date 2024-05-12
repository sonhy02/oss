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
IFS=

# 메뉴 표시 및 선택
while true; do
    echo "[MENU]"
    echo "1. Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in players.csv"
    echo         "2. Get the team data to enter a league position in teams.csv"
    echo         "3. Get the Top-3 Attendance matches in matches.csv"
    echo         "4. Get each team's ranking and the highest-scoring player"
    echo         "5. Get the modified format of date_GMT in matches.csv"
    echo         "6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
    echo         "7. Exit"
    read -p "Enter your CHOICE (1~7) : " choice
    
        case $choice in
            1)
                player_name="Heung-Min Son"
                csv_file="players.csv"
                read -p "Do you want to get the Heung-Min Son's data? (y/n) :" temp;
                if [ "$temp" = "y" ]; then
                    while IFS=, read -r full_name age position current_club nationality appearances goals assists; do
                        if [ "$full_name" = "$player_name" ]; then
                            echo "Team: $current_club, Appearance: $appearances, Goal: $goals, Assist: $assists"
                            echo
                        fi
                    done < "$csv_file"
                fi
                ;;
            2)
                read -p "Enter league position [1~20]: " league_position
                csv_file="teams.csv"
                while IFS=, read -r common_name wins draws losses points_per_game team_league_position cards_total shots fouls; do
                    if [ "$league_position" = "$team_league_position" ]; then
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
                    echo
                    sort -t',' -rk2,2 -n "$csv_file" | head -n 3 | while IFS=, read -r date_GMT attendance home_team_name away_team_name home_team_goal_count away_team_goal_count stadium_name; do
                        echo "$home_team_name vs $away_team_name ($date_GMT)"
                        echo "$attendance $stadium_name"
                        echo 
                    done
                    
                fi
                ;;
            4)
                read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n) : " choice
                if [ "$choice" = "y" ]; then

                    csv_teams="teams.csv"
                    csv_players="players.csv"

                    while IFS=, read -r common_name wins draws losses points_per_game team_league_position cards_total shots fouls; do
                        
                        highest_scorer=""
                        highest_score=0

                        while IFS=, read -r full_name age position current_club nationality appearances goals assists; do
                            if [ "$current_club" = "$common_name" ] && [ "$goals" -gt "$highest_score" ] ; then
                                highest_scorer="$full_name"
                                highest_score="$goals"
                            fi
                        done < <(sort -t',' -nk1,1 "$csv_players")
                        echo "$team_league_position $common_name"
                        echo "$highest_scorer $highest_score"
                        echo 
                    done < <(sort -t',' -nk6,6 "teams.csv" | tail -n +2)
                fi;;
            5)   read -p "Do you want to modify the format of date? (y/n) : " choice
            if [ $choice = y ]; then
            csv_file="matches.csv"
            awk -F, 'NR!=1&&NR<=11 {print $1}' $csv_file | 
            sed -e 's/Jan/01/g; s/Feb/02/g; s/Mar/03/g; s/Apr/04/g; s/May/05/g; s/Jun/06/g; s/Jul/07/g; s/Aug/08/g; s/Sep/09/g; s/Oct/10/g; s/Nov/11/g; s/Dec/12/g' | 
            sed -E 's/([0-9]+) ([0-9]+) ([0-9]+) - ([0-9]+:[0-9]+)(am|pm)/\3\/\1\/\2 \4\5/'
            echo
        fi
        ;;
            6) 
            PS3="Enter your team number: "
            IFS=$'\n'
            options=($(awk -F ',' 'NR > 1 {printf("%s\n", $1)}' teams.csv))
            select opt in ${options[@]}; do
                temp=$(awk -F, -v home=$opt -v max=-1 'max<($5-$6) && $3==home {max=$5-$6} END {print max}' matches.csv)
                echo
                echo $(awk -F, -v home=$opt -v dis=$temp '($5-$6)==dis && $3==home {printf("%s\n%s %d vs %d %s\n\n", $1, $3, $5, $6, $4)}' matches.csv)
                echo
                break
            done
            ;;
            7) echo "Bye!"; exit ;;
            *) echo "Invalid option. Please select a number between 1 and 7.";;
        esac
    
done
