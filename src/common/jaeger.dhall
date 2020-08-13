let k8s = ./imports.dhall

let jaeger =
      k8s.Container::{
      , name = "jaeger-agent"
      , image = Some
          "index.docker.io/sourcegraph/jaeger-agent:3.18.0@sha256:fbe6a333c1984befd37d09d18e20a1629d44331614bca223d95d30285474eea3"
      , ports = Some
        [ k8s.ContainerPort::{ containerPort = 5778, protocol = Some "TCP" }
        , k8s.ContainerPort::{ containerPort = 5775, protocol = Some "UDP" }
        , k8s.ContainerPort::{ containerPort = 6831, protocol = Some "UDP" }
        , k8s.ContainerPort::{ containerPort = 6832, protocol = Some "UDP" }
        ]
      , resources = Some k8s.ResourceRequirements::{
        , limits = Some (toMap { cpu = "1", memory = "500M" })
        , requests = Some (toMap { cpu = "100m", memory = "100M" })
        }
      , args = Some
        [ "--reporter.grpc.host-port=jaeger-collector:14250"
        , "--reporter.type=grpc"
        ]
      }

in  jaeger
