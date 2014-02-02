import 'dart:async' show Future;
import 'dart:convert';
import 'dart:io';
import "package:redis_client/redis_client.dart";

final InternetAddress HOST = InternetAddress.LOOPBACK_IP_V4;
final int PORT = 4040;

final String REDIS_CONNECTION = "localhost:6379";

void main() {
  new Dartra(HOST, PORT, REDIS_CONNECTION);
}

class Dartra {

  RedisClient client;

  /**
   * The constructor creates the HttpServer and the RedisClient.
   * Once both futures have successfully completed, the server
   * starts to listen for requests.
   */
  Dartra(InternetAddress host, int port, String redisConnection) {
    var futHttp = HttpServer.bind(host, port);
    var futRedis =  RedisClient.connect(redisConnection);

    Future.wait([futHttp, futRedis])
      .then((List responses) {
        HttpServer server = responses[0];
        this.client = responses[1];

        server.listen(this.handleRequest);
        print('The server is up and running...');
      })
      .catchError((e) => print('An error occurred.'));
  }

  /**
   * This method handles GET, POST, and PUT requests that are issued to
   * URIs of the scheme /:resource/:id. The data has to be in JSON format
   * and is fetched / persisted from a local Redis server.
   */
  void handleRequest(HttpRequest request) {
    if (request.uri.pathSegments.length == 2) {
      String resource = request.uri.pathSegments[0];
      String id = request.uri.pathSegments[1];
      String key = 'dartra:' + resource + ':' + id;

      switch (request.method) {
        case 'GET':
          this.client.get(key).then((value) {
           this.finishRequest(request.response, value, (value != null ? 200 : 404));
          });
          break;

        // Currently no distinction is made between POST and PUT requests.
        case 'POST':
        case 'PUT':
          UTF8.decodeStream(request).then((content) {
            try {
              JSON.decode(content);
              this.client.set(key, content).then((status) {
                this.finishRequest(request.response, content, (status == 'OK' ? (request.method == 'POST' ? 201 : 200) : 500));
              });

            } catch (ex) {
              // Data is not in JSON format
              this.finishRequest(request.response, null, 422);
            }
          });
          break;

        case 'DELETE':
          this.client.del(key).then((_) {
            this.finishRequest(request.response, null, 200);
          });
          break;
      }
    } else {
      this.finishRequest(request.response, null, 404);
    }
  }

  /**
   * Finishes the HttpResponse with the given output and status code.
   */
  void finishRequest(HttpResponse response, String output, int statusCode) {
    response.statusCode = statusCode;
    if (output != null) {
      response.headers.contentType = new ContentType("application", "json", charset: "utf-8");
      response.write(output);
    }
    response.close();
  }
}
