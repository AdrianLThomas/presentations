import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 10,
  duration: '10s'
};

export default function () {
  http.get('https://complexity-api.adrian-thomas.com?complexity=5');

  sleep(1);
}