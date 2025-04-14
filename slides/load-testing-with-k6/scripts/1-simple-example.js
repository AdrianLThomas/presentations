// Source: https://grafana.com/docs/k6/latest/get-started/write-your-first-test/

import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  iterations: 10,
};

export default function () {
  http.get('https://quickpizza.grafana.com');

  sleep(1);
}