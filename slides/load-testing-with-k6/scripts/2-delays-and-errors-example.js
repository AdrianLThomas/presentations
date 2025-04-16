import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 10,
  duration: '10s',
  thresholds: {
    http_req_failed: ['rate<0.05'], // http errors should be less than 5%
  },
};

export default function () {
  http.get('http://localhost:8787/?complexity=1&error-rate=0.01'); // errors 1% of the time

  sleep(0.1);
}