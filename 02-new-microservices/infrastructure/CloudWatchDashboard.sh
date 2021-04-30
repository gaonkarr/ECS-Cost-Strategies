REGION=$1
STACK_NAME=$2

PRIMARY='\033[0;34m'
NC='\033[0m' # No Color

# Fetch the stack metadata for use later
printf "${PRIMARY}* Fetching current stack state${NC}\n";

QUERY=$(cat <<-EOF
[
	Stacks[0].Outputs[?OutputKey==\`ClusterName\`].OutputValue,
	Stacks[0].Outputs[?OutputKey==\`ALBName\`].OutputValue,
	Stacks[0].Outputs[?OutputKey==\`ODASG\`].OutputValue,
	Stacks[0].Outputs[?OutputKey==\`SpotASG\`].OutputValue
]
EOF)

RESULTS=$(aws cloudformation describe-stacks \
	--stack-name $STACK_NAME \
	--region $REGION \
	--query "$QUERY" \
	--output text);
RESULTS_ARRAY=($RESULTS)

CLUSTER_NAME=${RESULTS_ARRAY[0]}
ALB_NAME=${RESULTS_ARRAY[1]}
OD_ASG=${RESULTS_ARRAY[2]}
SPOT_ASG=${RESULTS_ARRAY[3]}


DASHBOARD_SOURCECODE=$(cat <<-EOF
[{
    "widgets": [
        {
            "height": 6,
            "width": 9,
            "y": 6,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "CpuReserved", "ClusterName", "$CLUSTER_NAME", "ServiceName", "users", { "id": "mm0m0", "color": "#aec7e8" } ],
                    [ ".", "CpuUtilized", ".", ".", ".", ".", { "id": "mm1m0", "color": "#1f77b4" } ],
                    [ ".", "CpuReserved", ".", ".", ".", "posts", { "id": "mm0m2", "color": "#98df8a" } ],
                    [ ".", "CpuUtilized", ".", ".", ".", ".", { "id": "mm1m2", "color": "#2ca02c" } ],
                    [ ".", "CpuReserved", ".", ".", ".", "threads", { "id": "mm0m1", "color": "#ffbb78" } ],
                    [ ".", "CpuUtilized", ".", ".", ".", ".", { "id": "mm1m1", "color": "#ff7f0e" } ]
                ],
                "region": "$REGION",
                "title": "Services CPU Reservation & Utilization",
                "legend": {
                    "position": "bottom"
                },
                "timezone": "Local",
                "liveData": true,
                "period": 60,
                "yAxis": {
                    "left": {
                        "min": 0,
                        "showUnits": false,
                        "label": "Percent"
                    }
                },
                "view": "timeSeries",
                "stacked": false,
                "annotations": {
                    "horizontal": [
                        {
                            "label": "CPU",
                            "value": 100
                        }
                    ]
                },
                "stat": "Sum"
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 12,
            "x": 9,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "DesiredTaskCount", "ClusterName", "$CLUSTER_NAME", "ServiceName", "users" ],
                    [ "...", "threads" ],
                    [ "...", "posts" ],
                    [ ".", "ContainerInstanceCount", ".", ".", { "color": "#FFFF00", "label": "Container Instance Count", "visible": false } ]
                ],
                "region": "$REGION",
                "title": "Number of Desired Tasks",
                "legend": {
                    "position": "bottom"
                },
                "timezone": "Local",
                "liveData": true,
                "period": 60,
                "view": "timeSeries",
                "stacked": false,
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "stat": "Maximum"
            }
        },
        {
            "height": 6,
            "width": 9,
            "y": 12,
            "x": 0,
            "type": "metric",
            "properties": {
                "region": "$REGION",
                "title": "ECS Services Memory Utilization",
                "legend": {
                    "position": "right"
                },
                "timezone": "Local",
                "metrics": [
                    [ { "id": "expr1m0", "label": "users", "expression": "mm1m0 * 100 / mm0m0", "stat": "Average", "region": "$REGION" } ],
                    [ { "id": "expr1m1", "label": "threads", "expression": "mm1m1 * 100 / mm0m1", "stat": "Average", "region": "$REGION" } ],
                    [ { "id": "expr1m2", "label": "posts", "expression": "mm1m2 * 100 / mm0m2", "stat": "Average", "region": "$REGION" } ],
                    [ "ECS/ContainerInsights", "MemoryReserved", "ClusterName", "$CLUSTER_NAME", "ServiceName", "users", { "id": "mm0m0", "visible": false, "stat": "Sum" } ],
                    [ "...", "threads", { "id": "mm0m1", "visible": false, "stat": "Sum" } ],
                    [ "...", "posts", { "id": "mm0m2", "visible": false, "stat": "Sum" } ],
                    [ ".", "MemoryUtilized", ".", ".", ".", "users", { "id": "mm1m0", "visible": false, "stat": "Sum" } ],
                    [ "...", "threads", { "id": "mm1m1", "visible": false, "stat": "Sum" } ],
                    [ "...", "posts", { "id": "mm1m2", "visible": false, "stat": "Sum" } ]
                ],
                "liveData": true,
                "period": 60,
                "yAxis": {
                    "left": {
                        "min": 0,
                        "showUnits": false,
                        "label": "Percent"
                    }
                },
                "view": "timeSeries",
                "stacked": false
            }
        },
        {
            "height": 6,
            "width": 9,
            "y": 12,
            "x": 15,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "$OD_ASG", { "color": "#9467bd", "label": "On Demand Auto Scaling Group" } ],
                    [ "...", "$SPOT_ASG", { "color": "#d62728", "label": "Spot Auto Scaling Group" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "$REGION",
                "stat": "Average",
                "period": 60,
                "title": "AutoScalingGroups CPUUtilisation",
                "liveData": true,
                "annotations": {
                    "horizontal": [
                        {
                            "visible": false,
                            "label": "CPU",
                            "value": 100
                        }
                    ]
                }
            }
        },
        {
            "height": 6,
            "width": 9,
            "y": 0,
            "x": 15,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ECS/ManagedScaling", "CapacityProviderReservation", "ClusterName", "$CLUSTER_NAME", "CapacityProviderName", "OD-CP", { "label": "On Demand-CP", "color": "#9467bd", "visible": false } ],
                    [ "...", "SPOT-CP", { "yAxis": "left", "label": "Spot-CP", "color": "#d62728", "visible": false } ],
                    [ "AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", "$OD_ASG", { "color": "#9467bd", "label": "On Demand ASG" } ],
                    [ "...", "$SPOT_ASG", { "label": "Spot ASG" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "$REGION",
                "stat": "Maximum",
                "period": 60,
                "yAxis": {
                    "left": {
                        "label": "Total number of Instances",
                        "min": 0,
                        "showUnits": false
                    },
                    "right": {
                        "showUnits": false
                    }
                },
                "liveData": true,
                "title": "On Demand Capacity Provider GroupInServiceInstances",
                "legend": {
                    "position": "bottom"
                },
                "setPeriodToTimeRange": true,
                "annotations": {
                    "horizontal": [
                        {
                            "visible": false,
                            "label": "Min",
                            "value": 1
                        },
                        {
                            "visible": false,
                            "label": "Max",
                            "value": 30
                        }
                    ]
                }
            }
        },
        {
            "height": 6,
            "width": 9,
            "y": 0,
            "x": 0,
            "type": "metric",
            "properties": {
                "region": "$REGION",
                "title": "ECS Services CPU Utilization",
                "legend": {
                    "position": "bottom"
                },
                "timezone": "Local",
                "metrics": [
                    [ { "id": "expr1m0", "label": "users", "expression": "mm1m0 * 100 / mm0m0", "stat": "Average", "region": "$REGION" } ],
                    [ { "id": "expr1m1", "label": "threads", "expression": "mm1m1 * 100 / mm0m1", "stat": "Average", "region": "$REGION" } ],
                    [ { "id": "expr1m2", "label": "posts", "expression": "mm1m2 * 100 / mm0m2", "stat": "Average", "region": "$REGION" } ],
                    [ "ECS/ContainerInsights", "CpuReserved", "ClusterName", "$CLUSTER_NAME", "ServiceName", "users", { "id": "mm0m0", "visible": false, "stat": "Sum" } ],
                    [ "...", "threads", { "id": "mm0m1", "visible": false, "stat": "Sum" } ],
                    [ "...", "posts", { "id": "mm0m2", "visible": false, "stat": "Sum" } ],
                    [ ".", "CpuUtilized", ".", ".", ".", "users", { "id": "mm1m0", "visible": false, "stat": "Sum" } ],
                    [ "...", "threads", { "id": "mm1m1", "visible": false, "stat": "Sum" } ],
                    [ "...", "posts", { "id": "mm1m2", "visible": false, "stat": "Sum" } ]
                ],
                "liveData": true,
                "period": 60,
                "yAxis": {
                    "left": {
                        "min": 0,
                        "showUnits": false,
                        "label": "Percent"
                    }
                },
                "view": "timeSeries",
                "stacked": false,
                "annotations": {
                    "horizontal": [
                        {
                            "label": "CPU",
                            "value": 100
                        }
                    ]
                }
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 9,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ ".", "ActiveConnectionCount", "LoadBalancer", "ALB_NAME", { "id": "m4" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "$REGION",
                "stat": "Sum",
                "period": 60,
                "title": "ALB ActiveConnectionCount",
                "liveData": true
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 6,
            "x": 9,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "RunningTaskCount", "ClusterName", "$CLUSTER_NAME", "ServiceName", "users" ],
                    [ "...", "threads" ],
                    [ "...", "posts" ],
                    [ ".", "ContainerInstanceCount", ".", ".", { "color": "#FFFF00", "label": "Container Instance Count" } ]
                ],
                "region": "$REGION",
                "title": "Number of Running Tasks",
                "legend": {
                    "position": "bottom"
                },
                "timezone": "Local",
                "liveData": true,
                "period": 60,
                "view": "timeSeries",
                "stacked": false,
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "stat": "Maximum"
            }
        },
        {
            "height": 6,
            "width": 9,
            "y": 6,
            "x": 15,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/AutoScaling", "GroupTotalInstances", "AutoScalingGroupName", "$OD_ASG", { "id": "m1", "label": "On Demand GroupTotalInstances", "visible": false } ],
                    [ { "expression": "m1 * 0.117", "label": "On-Demand hrly", "id": "e1", "region": "$REGION", "period": 60, "stat": "Maximum", "color": "#9467bd" } ],
                    [ { "expression": "m2 * 0.0319", "label": "Spot hrly", "id": "e2", "region": "$REGION", "color": "#d62728" } ],
                    [ "AWS/AutoScaling", "GroupTotalInstances", "AutoScalingGroupName", "$SPOT_ASG", { "id": "m2", "visible": false, "label": "Spot GroupTotalInstances" } ]
                ],
                "view": "timeSeries",
                "region": "$REGION",
                "stat": "Maximum",
                "period": 60,
                "setPeriodToTimeRange": false,
                "stacked": false,
                "title": "EC2 Spot & On Demand Cost",
                "singleValueFullPrecision": false,
                "liveData": true,
                "yAxis": {
                    "left": {
                        "label": "USD",
                        "min": 0,
                        "showUnits": false
                    },
                    "right": {
                        "showUnits": false
                    }
                }
            }
        }
    ]
}]
EOF)

RESULT=`aws cloudwatch put-dashboard \
				--region $REGION \
				--dashboard-name new_microservices \
				--dashboard-body  $DASHBOARD_SOURCECODE`