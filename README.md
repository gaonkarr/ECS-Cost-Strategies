
# Strategies for cost driven architectures


This is a reference architecture that shows the evolution of a Node.js application from a monolithic
application that is deployed directly onto instances with no containerization or orchestration, to a
containerized microservices architecture orchestrated using Amazon EC2 Container Service.


## Node.js Microservices Deployed on EC2 Container Service

This is a sample demonstration of how to implement strategies for implementing cost driven architectures.

In this sample, we will implement some of the strategies discussed here into a Microservices Nodejs sample application. Lets call it Old (pre-applying some of these strategies) and New(after implementing strategies).

For deployment follow steps in each folder : 

- [Part One: The base Node.js application](01-old-microservices/)
- [Part Two: Moving the application to a container deployed using ECS](02-new-microservices/)



## Some of the common strategies are listen below :


__Isolation of crashes:__ 

__Isolation for security:__ 

__Independent scaling:__ 

__Development velocity__: 


__Define microservice boundaries:__ 

__Stitching microservices together:__ 

__Chipping away slowly:__ 


![Reference architecture of microservices on EC2 Container Service](../images/microservice-containers.png)

## References & More
