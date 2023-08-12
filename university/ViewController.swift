import UIKit
import SnapKit
import Alamofire

struct Welcome: Codable {
    let status: String
    let statusCode: Int
    let version, access: String
    let data: [String: Datum]

    enum CodingKeys: String, CodingKey {
        case status
        case statusCode = "status-code"
        case version, access, data
    }
}

struct Datum: Codable {
    let country: String
    let region: Region
}

enum Region: String, Codable {
    case africa = "Africa"
    case antarctic = "Antarctic"
    case asia = "Asia"
    case centralAmerica = "Central America"
}

class ViewController: UIViewController {
    func flag(from country: String) -> String {
        let base: UInt32 = 127397
        var s = ""
        for v in country.uppercased().unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return s
    }

    let tableView = UITableView()
    var countryData = [String: Datum]()
    var country: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        configureTableView()
        configureNavigationBar()
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        fetchData()
    }

    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    func configureNavigationBar() {
        navigationItem.title = "Список стран мира"
    }

    func fetchData() {
        AF.request("https://api.first.org/data/v1/countries").responseData { response in
            switch response.result {
            case .success(let jsonData):
                let decoder = JSONDecoder()
                if let response = try? decoder.decode(Welcome.self, from: jsonData), response.statusCode == 200 {
                    self.countryData = response.data
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let country = Array(countryData.keys)[indexPath.row]
        let flag = self.flag(from: country)
        cell.textLabel?.text = flag
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = Array(countryData.values)[indexPath.row]
        
        let secondViewController = SecondViewController(country: country)
        navigationController?.pushViewController(secondViewController, animated: true)
    }
}

struct University: Codable {
    let name: String
    let domains: [String]
    let alphaTwoCode: String
    let stateProvince: String?
    let webPages: [String]
    let country: String

    enum CodingKeys: String, CodingKey {
        case name, domains, alphaTwoCode, stateProvince, webPages, country
    }
}

typealias Universities = [University]

class SecondViewController: UIViewController {
    let tableView = UITableView()
    var universities = [University]()
    let country: Datum

    init(country: Datum) {
        self.country = country
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        configureTableView()
        configureNavigationBar()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        fetchData()
    }

    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    func configureNavigationBar() {
        navigationItem.title = country.country
    }

    func fetchData() {
        let url = "http://universities.hipolabs.com/search?country=\(country.country)"

        AF.request(url).responseData { response in
            switch response.result {
            case .success(let jsonData):
                let decoder = JSONDecoder()
                if let response = try? decoder.decode(Universities.self, from: jsonData), response.count > 0 {
                    self.universities = response
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension SecondViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return universities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let university = universities[indexPath.row]
        cell.textLabel?.text = "\(university.name) (\(university.alphaTwoCode))"
        return cell
    }
}
