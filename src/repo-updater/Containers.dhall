let k8s = ../common/imports.dhall

let config = ./Config.dhall

let containerConfig =
      { name = config.name
      , repo = config.repo
      , tag = config.tag
      , ports = config.ports
      , resources = config.resources
      }

let repoUpdater =
      k8s.Container::{
      , name = containerConfig.name
      , image = Some "${containerConfig.repo}:${containerConfig.tag}"
      , ports = Some containerConfig.ports
      , resources = Some containerConfig.resources
      }

let jaeger = ../common/jaeger.dhall

in  [ repoUpdater, jaeger ]
