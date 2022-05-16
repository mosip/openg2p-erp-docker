#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: ./apply-istio-ingress.sh <NS> <hostname> [erp-service-name] [istio-selector]"
fi

if [ -z "$3" ] || [ "$3" = "." ] ; then
    ERP_SERVICE_NAME="openg2p-erp-odoo"
else
    ERP_SERVICE_NAME="$3"
fi

if [ -z "$4" ]; then
    ISTIO_SELECTOR="istio: ingressgateway"
else
    ISTIO_SELECTOR="$4"
fi

echo "
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: openg2p-erp
spec:
  gateways:
  - openg2p-erp
  hosts:
  - '*'
  http:
  - headers:
      request:
        set:
          x-forwarded-proto: https
    route:
    - destination:
        host: ___erp-service-name___
        port:
          number: 80
---
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: openg2p-erp
spec:
  selector:
    ___istio-ingress-selector___
  servers:
  - hosts:
    - ___hostname___
    port:
      name: http
      number: 80
      protocol: HTTP
" > /tmp/istio.res.yaml

cat /tmp/istio.res.yaml | \
sed "s/___hostname___/$2/g" | \
sed "s/___istio-ingress-selector___/$ISTIO_SELECTOR/g" | \
sed "s/___erp-service-name___/$ERP_SERVICE_NAME/g" | \
kubectl apply -n $1 -f -