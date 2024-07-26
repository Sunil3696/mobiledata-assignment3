//
//  SearchViewController.swift
//  MovieSearchApp-Sunil(Ass3)
//
//  Created by Sunil Balami on 2024-07-25.
//

import Foundation
import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
      var movies: [Movie] = []
      var filteredMovies: [Movie] = []

      override func viewDidLoad() {
          super.viewDidLoad()
          searchBar.delegate = self
          tableView.dataSource = self
          tableView.delegate = self
      }
    
    
    @IBAction func searchButtonTouched(_ sender: UIButton) {
        
        let searchParam = searchBar.searchTextField.text!
        
//        print(searchParam)
        fetchMovies(query: searchParam)
    }
    
//      func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//          fetchMovies(query: searchText)
//      }

      func fetchMovies(query: String) {
          let urlString = "https://www.omdbapi.com/?s=\(query)&apikey=576b4e31"
          guard let url = URL(string: urlString) else { return }

          let task = URLSession.shared.dataTask(with: url) { data, response, error in
              guard let data = data, error == nil else { return }

              do {
                  let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                  var movies: [Movie] = []
                  let group = DispatchGroup()

                  for movie in searchResult.Search {
                      group.enter()
                      let detailURLString = "https://www.omdbapi.com/?i=\(movie.imdbID)&apikey=576b4e31"
                      guard let detailURL = URL(string: detailURLString) else { continue }

                      URLSession.shared.dataTask(with: detailURL) { detailData, _, _ in
                          if let detailData = detailData {
                              if let detailedMovie = try? JSONDecoder().decode(Movie.self, from: detailData) {
                                  movies.append(detailedMovie)
                              }
                          }
                          group.leave()
                      }.resume()
                  }

                  group.notify(queue: .main) {
                      self.movies = movies
                      self.tableView.reloadData()
                  }

              } catch {
                  print("Error decoding data: \(error)")
              }
          }
          task.resume()
      }

      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return movies.count
      }

      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
          let movie = movies[indexPath.row]
          cell.titleLabel.text = movie.Title
          cell.studioLabel.text = movie.Genre
          cell.yearLabel.text = movie.Year

          if let posterURL = movie.Poster, let url = URL(string: posterURL) {
              DispatchQueue.global().async {
                  if let data = try? Data(contentsOf: url) {
                      DispatchQueue.main.async {
                          cell.posterImageView.image = UIImage(data: data)
                          cell.setNeedsLayout()
                      }
                  }
              }
          } else {
              cell.posterImageView.image = nil
          }
          return cell
      }

      override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == "ShowMovieDetail",
             let indexPath = tableView.indexPathForSelectedRow {
              let detailVC = segue.destination as! DetailViewController
              let selectedMovie = movies[indexPath.row]
              detailVC.imdbID = selectedMovie.imdbID
          }
      }
  }

  struct SearchResult: Codable {
      let Search: [Movie]
  }

  struct Movie: Codable {
      let Title: String
      let Year: String
      let imdbID: String
      let Poster: String?
      let Genre: String?
      let Rated: String? // Ensure this is nullable in case it's not always available
  }
    

