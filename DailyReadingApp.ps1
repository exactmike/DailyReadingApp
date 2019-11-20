Import-Module UniversalDashboard

$sched = New-UDEndpointSchedule -Every 30 -Second
$exp = New-UDEndpoint -Endpoint {
    $cache:experiment = Get-Date
} -Schedule $sched

$Dashboard = New-UDDashboard -Title 'Daily Reading App' -Content {
    New-UDHeading -Text 'Daily Reading App'
    New-UDCollapsible -Items {
        New-UDCollapsibleItem -icon arrow_circle_o_down -Title 'Day of the Year' -Content {
            New-UDCounter -Endpoint {
                $cache:date = Get-Date
                $cache:date.DayOfYear
            }
        }
        New-UDCollapsibleItem -Icon arrow_circle_o_down -Title 'Proverbs chapter of the day' -Content {
            New-UDCounter -Endpoint {
                $cache:date.day
            }
        }

        New-UDCollapsibleItem -Icon arrow_circle_o_down -Title $(
            if ($session:date.DayOfYear -gt 300) { 'Psalm of the Day' } else { 'Advent reading of the day' }
        ) -content {
            switch ($true)
            {
                { $cache:date.dayofyear -le 150 }
                {
                    New-UDCounter -Endpoint {
                        $cache:date.dayofyear
                    }
                }
                { $cache:date.dayofyear -gt 150 -and $cache:date.dayofyear -le 300 }
                {
                    New-UDCounter -Endpoint {
                        300 - $_
                    }
                }
                { $cache:date.dayofyear -gt 300 }
                {
                    New-UDCard -Endpoint {
                        $Double = $cache:date.day * 2
                        $Chapters = "" + $($Double - 1) + ' - ' + $($Double)
                        "Isaiah $Chapters"
                    }
                }
            }
        }
    }

    New-UDCard -Endpoint {
        "The latest retrieved time is $($cache:experiment)"
    }
}


Start-UDDashboard -Dashboard $Dashboard -AutoReload -AdminMode -Port 8001 -Endpoint $exp
