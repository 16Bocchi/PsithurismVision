import Foundation

struct HeartRate: Identifiable, Decodable {
    let id = UUID()
    let time: Int
    let rate: Double

    enum CodingKeys: String, CodingKey {
        case time = "timestamp"
        case rate = "heartRate"
    }
}

struct SessionData: Decodable {
    let heartRate: Double
    let timestamp: Int
}

struct FirebaseService {
    let baseURL = apiKeyInfo.baseURL
    let apiKey = apiKeyInfo.apiKey

    func getSessionCount(completion: @escaping (Int) -> Void) {
        guard let url = URL(string: "\(baseURL)sessionsCount.json?auth=\(apiKey)") else {
            print("Invalid URL")
            completion(0)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error retrieving session count: \(error?.localizedDescription ?? "Unknown error")")
                completion(0)
                return
            }

            do {
                let sessionCount = try JSONDecoder().decode(Int?.self, from: data) ?? 0
                completion(sessionCount)
            } catch {
                print("Error decoding session count: \(error.localizedDescription)")
                completion(0)
            }
        }.resume()
    }
    func fetchData(nodePath: String, completion: @escaping (Result<Double, Error>) -> Void) {
           guard let url = URL(string: "\(baseURL)\(nodePath).json?auth=\(apiKey)") else {
               print("Invalid URL")
               completion(.failure(FirebaseError.invalidURL))
               return
           }

           let request = URLRequest(url: url)

           URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
                   completion(.failure(error))
                   return
               }

               guard let data = data else {
                   completion(.failure(FirebaseError.noData))
                   return
               }

               do {
                   if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let latestEntry = jsonResponse.values.compactMap({ $0 as? [String: Any] }).sorted(by: { ($0["timestamp"] as? Int ?? 0) > ($1["timestamp"] as? Int ?? 0) }).first,
                      let heartRate = latestEntry["heartRate"] as? Double {
                       completion(.success(heartRate))
                   } else {
                       completion(.failure(FirebaseError.invalidResponse))
                   }
               } catch {
                   completion(.failure(error))
               }
           }.resume()
       }

       enum FirebaseError: Error {
           case invalidURL
           case noData
           case invalidResponse
       }

    func fetchAllSessionIDs(completion: @escaping ([String]) -> Void) {
        getSessionCount { sessionCount in
            let sessionIDs = (1...sessionCount).reversed().map { "\($0)" }
            completion(Array(sessionIDs))
        }
    }

    func fetchHeartRates(for sessionID: String, completion: @escaping ([HeartRate]?) -> Void) {
        guard let url = URL(string: "\(baseURL)sessions/\(sessionID).json?auth=\(apiKey)") else {
            print("Invalid URL")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching heart rates: \(error)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            do {
                let decoder = JSONDecoder()
                let heartRatesDict = try decoder.decode([String: SessionData].self, from: data)
                let heartRates = heartRatesDict.values.map { HeartRate(time: $0.timestamp, rate: $0.heartRate) }
//                print("Fetched heart rates for session \(sessionID): \(heartRates)")
                completion(heartRates)
            } catch {
                print("Error decoding heart rates: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
