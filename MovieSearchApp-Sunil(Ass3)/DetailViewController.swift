//
//  DetailViewController.swift
//  MovieSearchApp-Sunil(Ass3)
//
//  Created by Sunil Balami on 2024-07-25.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var yearLabel: UILabel!
    
    @IBOutlet weak var ratedLabel: UILabel!
    
    
    @IBOutlet weak var releasedLabel: UILabel!
    
    @IBOutlet weak var runtimeLabel: UILabel!
    
    
    
    @IBOutlet weak var genreLabel: UILabel!
    
    @IBOutlet weak var directorLabel: UILabel!
    
    @IBOutlet weak var writerLabel: UILabel!
    
    @IBOutlet weak var actorsLabel: UILabel!
    
    @IBOutlet weak var plotLabel: UILabel!
    
    
    @IBOutlet weak var languageLabel: UILabel!
    
    @IBOutlet weak var countryLabel: UILabel!
    
    @IBOutlet weak var posterImageView: UIImageView!
    
    var imdbID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let imdbID = imdbID {
            fetchMovieDetails(imdbID: imdbID)
        }
    }

    func fetchMovieDetails(imdbID: String) {
        let urlString = "https://www.omdbapi.com/?i=\(imdbID)&apikey=576b4e31"
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }

            do {
                let movieDetails = try JSONDecoder().decode(MovieDetails.self, from: data)
                DispatchQueue.main.async {
                    self.updateUI(with: movieDetails)
                }
            } catch {
                print("Error decoding data: \(error)")
            }
        }
        task.resume()
    }

    func updateUI(with movie: MovieDetails) {
        titleLabel.text = movie.Title
        yearLabel.text = movie.Year
        ratedLabel.text = movie.Rated
        releasedLabel.text = movie.Released
        runtimeLabel.text = movie.Runtime
        genreLabel.text = movie.Genre
        directorLabel.text = movie.Director
        writerLabel.text = movie.Writer
        actorsLabel.text = movie.Actors
        plotLabel.text = movie.Plot
        languageLabel.text = movie.Language
        countryLabel.text = movie.Country

        if let posterURL = movie.Poster, let url = URL(string: posterURL) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.posterImageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }
}

struct MovieDetails: Codable {
    let Title: String
    let Year: String
    let Rated: String
    let Released: String
    let Runtime: String
    let Genre: String
    let Director: String
    let Writer: String
    let Actors: String
    let Plot: String
    let Language: String
    let Country: String
    let Poster: String?
}
    

