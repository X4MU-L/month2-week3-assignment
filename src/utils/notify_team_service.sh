# configuration
TEAMS_WEBHOOK=${WEEK2_TEAMS_WEBHOOK_ENV:-"https://prod-249.westeurope.logic.azure.com:443/workflows/de760063dc854c389ead0aa64fa3c3c9/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=5pAsUIINsBNyJ6fTJu6cSZGPm8AXODVOZxs9mB4XOaI"}

# Send notification to Teams
notify_teams() {
    local current_time="$1"
    local system_health="$2"
    local cpu_usage="$3"
    local disk_usage="$4"
    local memory_usage="$5"

    # Create JSON payload using printf for better control and escaping
    local json_payload=$(printf '{
    "type": "message",
    "attachments": [
        {
            "contentType": "application/vnd.microsoft.card.adaptive",
            "contentUrl": null,
            "content": {
                "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                "type": "AdaptiveCard",
                "version": "1.2",
                "body": [
                    {
                        "type": "TextBlock",
                        "size": "Medium",
                        "weight": "Bolder",
                        "text": "%s - System Status Report",
                        "style": "heading",
                        "wrap": true
                    },
                    {
                        "type": "ColumnSet",
                        "columns": [
                            {
                                "type": "Column",
                                "items": [
                                    {
                                        "type": "Image",
                                        "style": "Person",
                                        "url": "https://media.licdn.com/dms/image/v2/D4D03AQEDvCuYlMuGrg/profile-displayphoto-shrink_200_200/profile-displayphoto-shrink_200_200/0/1731597654077?e=2147483647&v=beta&t=kHBaSHAVCBTrZKkosRrcemCbM6gSu6N-vpeQ67VhsQ8",
                                        "altText": "Chukwuebuka",
                                        "size": "Small"
                                    }
                                ],
                                "width": "auto"
                            },
                            {
                                "type": "Column",
                                "items": [
                                    {
                                        "type": "TextBlock",
                                        "weight": "Bolder",
                                        "text": "Chukwuebuka",
                                        "wrap": true
                                    },
                                    {
                                        "type": "TextBlock",
                                        "spacing": "None",
                                        "text": "Created {{DATE(%sT%sZ, SHORT)}}",
                                        "isSubtle": true,
                                        "wrap": true
                                    }
                                ],
                                "width": "stretch"
                            }
                        ]
                    },
                    {
                        "type": "TextBlock",
                        "text": "This is the system report of my local system - just testing out the webhooks 😪",
                        "wrap": true
                    },
                    {
                        "type": "FactSet",
                        "facts": [
                            {
                                "title": "Time:",
                                "value": "%s"
                            },
                            {
                                "title": "Health:",
                                "value": "%s"
                            },
                            {
                                "title": "CPU_Usage:",
                                "value": "%s"
                            },
                            {
                                "title": "Disk:",
                                "value": "%s"
                            },
                            {
                                "title": "Memory:",
                                "value": "%s"
                            }
                        ],
                        "separator": true
                    }
                ]
            }
        }
    ]
}' "$current_time" "$(date +%Y-%m-%d)" "$(date +%H:%M:%S)" "$current_time" "$system_health" "$cpu_usage" "$disk_usage" "$memory_usage")

    # Send to Teams webhook
    curl -H "Content-Type: application/json" \
         -d "$json_payload" \
         "$TEAMS_WEBHOOK"
}