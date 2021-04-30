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
	Stacks[0].Outputs[?OutputKey==\`ASG\`].OutputValue
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
ASG=${RESULTS_ARRAY[2]}

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
                "region": "$REGION",
                "title": "CPU Utilization",
                "legend": {
                    "position": "right"
                },
                "timezone": "Local",
                "metrics": [
                    [ { "id": "expr1m0", "label": "users", "expression": "mm1m0 * 100 / mm0m0", "stat": "Average" } ],
                    [ { "id": "expr1m1", "label": "threads", "expression": "mm1m1 * 100 / mm0m1", "stat": "Average" } ],
                    [ { "id": "expr1m2", "label": "posts", "expression": "mm1m2 * 100 / mm0m2", "stat": "Average" } ],
                    [ "ECS/ContainerInsights", "CpuReserved", "ClusterName", "$CLUSTER_NAME", "ServiceName", "users", { "id": "mm0m0", "visible": false, "stat": "Sum" } ],
                    [ "...", "threads", { "id": "mm0m1", "visible": false, "stat": "Sum" } ],
                    [ "...", "posts", { "id": "mm0m2", "visible": false, "stat": "Sum" } ],
                    [ ".", "CpuUtilized", ".", ".", ".", "users", { "id": "mm1m0", "visible": false, "stat": "Sum" } ],
                    [ "...", "threads", { "id": "mm1m1", "visible": false, "stat": "Sum" } ],
                    [ "...", "posts", { "id": "mm1m2", "visible": false, "stat": "Sum" } ]
                ],
                "liveData": false,
                "period": 60,
                "yAxis": {
                    "left": {
                        "min": 0,
                        "showUnits": false,
                        "label": "Percent"
                    }
                }
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
                "title": "Memory Utilization",
                "legend": {
                    "position": "right"
                },
                "timezone": "Local",
                "metrics": [
                    [ { "id": "expr1m0", "label": "users", "expression": "mm1m0 * 100 / mm0m0", "stat": "Average" } ],
                    [ { "id": "expr1m1", "label": "threads", "expression": "mm1m1 * 100 / mm0m1", "stat": "Average" } ],
                    [ { "id": "expr1m2", "label": "posts", "expression": "mm1m2 * 100 / mm0m2", "stat": "Average" } ],
                    [ "ECS/ContainerInsights", "MemoryReserved", "ClusterName", "$CLUSTER_NAME", "ServiceName", "users", { "id": "mm0m0", "visible": false, "stat": "Sum" } ],
                    [ "...", "threads", { "id": "mm0m1", "visible": false, "stat": "Sum" } ],
                    [ "...", "posts", { "id": "mm0m2", "visible": false, "stat": "Sum" } ],
                    [ ".", "MemoryUtilized", ".", ".", ".", "users", { "id": "mm1m0", "visible": false, "stat": "Sum" } ],
                    [ "...", "threads", { "id": "mm1m1", "visible": false, "stat": "Sum" } ],
                    [ "...", "posts", { "id": "mm1m2", "visible": false, "stat": "Sum" } ]
                ],
                "liveData": false,
                "period": 60,
                "yAxis": {
                    "left": {
                        "min": 0,
                        "showUnits": false,
                        "label": "Percent"
                    }
                }
            }
        },
        {
            "height": 6,
            "width": 4,
            "y": 27,
            "x": 4,
            "type": "metric",
            "properties": {
                "region": "$REGION",
                "title": "Network TX",
                "legend": {
                    "position": "right"
                },
                "timezone": "Local",
                "metrics": [
                    [ { "id": "expr1m0", "label": "users", "expression": "mm0m0", "stat": "Average" } ],
                    [ { "id": "expr1m1", "label": "threads", "expression": "mm0m1", "stat": "Average" } ],
                    [ { "id": "expr1m2", "label": "posts", "expression": "mm0m2", "stat": "Average" } ],
                    [ "ECS/ContainerInsights", "NetworkTxBytes", "ClusterName", "$CLUSTER_NAME", "ServiceName", "users", { "id": "mm0m0", "visible": false, "stat": "Average" } ],
                    [ "...", "threads", { "id": "mm0m1", "visible": false, "stat": "Average" } ],
                    [ "...", "posts", { "id": "mm0m2", "visible": false, "stat": "Average" } ]
                ],
                "liveData": false,
                "period": 60,
                "yAxis": {
                    "left": {
                        "showUnits": false,
                        "label": "Bytes/Second"
                    }
                }
            }
        },
        {
            "height": 6,
            "width": 4,
            "y": 21,
            "x": 16,
            "type": "metric",
            "properties": {
                "region": "$REGION",
                "title": "Network RX",
                "legend": {
                    "position": "right"
                },
                "timezone": "Local",
                "metrics": [
                    [ { "id": "expr1m0", "label": "users", "expression": "mm0m0", "stat": "Average" } ],
                    [ { "id": "expr1m1", "label": "threads", "expression": "mm0m1", "stat": "Average" } ],
                    [ { "id": "expr1m2", "label": "posts", "expression": "mm0m2", "stat": "Average" } ],
                    [ "ECS/ContainerInsights", "NetworkRxBytes", "ClusterName", "$CLUSTER_NAME", "ServiceName", "users", { "id": "mm0m0", "visible": false, "stat": "Average" } ],
                    [ "...", "threads", { "id": "mm0m1", "visible": false, "stat": "Average" } ],
                    [ "...", "posts", { "id": "mm0m2", "visible": false, "stat": "Average" } ]
                ],
                "liveData": false,
                "period": 60,
                "yAxis": {
                    "left": {
                        "showUnits": false,
                        "label": "Bytes/Second"
                    }
                }
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 27,
            "x": 13,
            "type": "metric",
            "properties": {
                "region": "$REGION",
                "title": "Number of Desired Tasks",
                "legend": {
                    "position": "bottom"
                },
                "timezone": "Local",
                "metrics": [
                    [ "ECS/ContainerInsights", "DesiredTaskCount", "ClusterName", "$CLUSTER_NAME", "ServiceName", "users", { "stat": "Average" } ],
                    [ "...", "threads", { "stat": "Average" } ],
                    [ "...", "posts", { "stat": "Average" } ]
                ],
                "liveData": false,
                "period": 60
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 18,
            "type": "metric",
            "properties": {
                "region": "$REGION",
                "title": "Number of Running Tasks",
                "legend": {
                    "position": "bottom"
                },
                "timezone": "Local",
                "metrics": [
                    [ "ECS/ContainerInsights", "RunningTaskCount", "ClusterName", "$CLUSTER_NAME", "ServiceName", "users", { "stat": "Average" } ],
                    [ "...", "threads", { "stat": "Average" } ],
                    [ "...", "posts", { "stat": "Average" } ]
                ],
                "liveData": false,
                "period": 60
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 33,
            "x": 18,
            "type": "metric",
            "properties": {
                "region": "$REGION",
                "title": "Number of Pending Tasks",
                "legend": {
                    "position": "bottom"
                },
                "timezone": "Local",
                "metrics": [
                    [ "ECS/ContainerInsights", "PendingTaskCount", "ClusterName", "$CLUSTER_NAME", "ServiceName", "users", { "stat": "Average" } ],
                    [ "...", "threads", { "stat": "Average" } ],
                    [ "...", "posts", { "stat": "Average" } ]
                ],
                "liveData": false,
                "period": 60
            }
        },
        {
            "height": 6,
            "width": 9,
            "y": 21,
            "x": 5,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", "$ASG", { "color": "#9467bd", "label": "AWS/AutoScaling GroupInServiceInstances", "visible": false } ],
                    [ "ECS/ContainerInsights", "DesiredTaskCount", "ServiceName", "users", "ClusterName", "$CLUSTER_NAME", { "visible": false } ],
                    [ ".", "RunningTaskCount", ".", "posts", ".", "." ],
                    [ ".", "CpuUtilized", ".", ".", ".", ".", { "color": "#98df8a" } ],
                    [ ".", "RunningTaskCount", ".", "threads", ".", ".", { "color": "#ff7f0e" } ],
                    [ ".", "CpuUtilized", ".", ".", ".", ".", { "color": "#ffbb78" } ],
                    [ ".", "RunningTaskCount", ".", "users", ".", ".", { "color": "#1f77b4" } ],
                    [ ".", "CpuUtilized", ".", ".", ".", ".", { "color": "#aec7e8" } ]
                ],
                "view": "timeSeries",
                "stacked": true,
                "region": "$REGION",
                "stat": "Average",
                "period": 60,
                "yAxis": {
                    "right": {
                        "max": 30,
                        "min": 0,
                        "label": "Task_Count",
                        "showUnits": true
                    },
                    "left": {
                        "label": "CPUUtilization",
                        "min": 0,
                        "showUnits": false
                    }
                },
                "setPeriodToTimeRange": true,
                "liveData": true,
                "title": "Services_CPUUtilisation"
            }
        },
        {
            "height": 6,
            "width": 9,
            "y": 6,
            "x": 9,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "$ASG", { "color": "#9467bd" } ]
                ],
                "view": "timeSeries",
                "stacked": true,
                "region": "$REGION",
                "stat": "Average",
                "period": 60,
                "title": "AutoScalingGroup-Max-CPUUtilisation",
                "liveData": true
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 6,
            "x": 18,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", "$ASG", { "color": "#9467bd" } ]
                ],
                "view": "timeSeries",
                "stacked": true,
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
                "title": "Instances in AutoScalingGroup",
                "legend": {
                    "position": "bottom"
                },
                "setPeriodToTimeRange": true
            }
        },
        {
            "height": 6,
            "width": 9,
            "y": 0,
            "x": 9,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ ".", "ActiveConnectionCount", "LoadBalancer", "$ALB_NAME", { "color": "#FFFF00", "label": "app/ELB ActiveConnectionCount" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "$REGION",
                "stat": "Sum",
                "period": 60,
                "title": "ALB-Counts",
                "yAxis": {
                    "left": {
                        "label": "Request Counts"
                    }
                },
                "liveData": true,
                "legend": {
                    "position": "bottom"
                }
            }
        },
        {
            "height": 9,
            "width": 15,
            "y": 12,
            "x": 9,
            "type": "explorer",
            "properties": {
                "metrics": [
                    {
                        "metricName": "CPUUtilization",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "SampleCount"
                    }
                ],
                "aggregateBy": {
                    "key": "*",
                    "func": "SUM"
                },
                "labels": [
                    {
                        "key": "InstanceLifecycle",
                        "value": "spot"
                    },
                    {
                        "key": "InstanceLifecycle",
                        "value": "on-demand"
                    },
                    {
                        "key": "aws:cloudformation:stack-name",
                        "value": "ECS-Pre-Cost-Arch"
                    }
                ],
                "widgetOptions": {
                    "legend": {
                        "position": "hidden"
                    },
                    "view": "timeSeries",
                    "stacked": false,
                    "rowsPerPage": 1,
                    "widgetsPerRow": 1
                },
                "period": 60,
                "splitBy": "InstanceLifecycle",
                "region": "$REGION"
            }
        },
        {
            "height": 6,
            "width": 9,
            "y": 0,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ { "id": "expr1m0", "label": "users", "expression": "mm1m0 * 100 / mm0m0", "stat": "Average", "region": "$REGION", "visible": false } ],
                    [ { "id": "expr1m1", "label": "threads", "expression": "mm1m1 * 100 / mm0m1", "stat": "Average", "region": "$REGION", "visible": false } ],
                    [ { "id": "expr1m2", "label": "posts", "expression": "mm1m2 * 100 / mm0m2", "stat": "Average", "region": "$REGION", "visible": false } ],
                    [ "ECS/ContainerInsights", "CpuReserved", "ClusterName", "$CLUSTER_NAME", "ServiceName", "users", { "id": "mm0m0", "color": "#aec7e8" } ],
                    [ ".", "CpuUtilized", ".", ".", ".", ".", { "id": "mm1m0", "color": "#1f77b4" } ],
                    [ ".", "CpuReserved", ".", ".", ".", "posts", { "id": "mm0m2", "color": "#98df8a" } ],
                    [ ".", "CpuUtilized", ".", ".", ".", ".", { "id": "mm1m2", "color": "#2ca02c" } ],
                    [ ".", "CpuReserved", ".", ".", ".", "threads", { "id": "mm0m1", "color": "#ffbb78" } ],
                    [ ".", "CpuUtilized", ".", ".", ".", ".", { "id": "mm1m1", "color": "#ff7f0e" } ]
                ],
                "region": "$REGION",
                "title": "Services CPU Reservation and Utilization",
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
                        "label": ""
                    }
                },
                "view": "timeSeries",
                "stacked": false,
                "stat": "Sum",
                "setPeriodToTimeRange": true
            }
        }
    ]
}]
EOF)

RESULT=`aws cloudwatch put-dashboard \
				--region $REGION \
				--dashboard-name old_microservices \
				--dashboard-body  $DASHBOARD_SOURCECODE`