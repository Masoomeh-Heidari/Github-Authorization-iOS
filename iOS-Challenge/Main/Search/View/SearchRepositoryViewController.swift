//
//  SearchRepositoryViewController.swift
//  iOS-Challenge
//
//  Created by Fariba Heidari on 3/20/1399 AP.
//  Copyright © 1399 AP Farshad Mousalou. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback

let startLoadingOffset: CGFloat = 20.0
let reuseIdentifier = "Cell"

class SearchRepositoryViewController: ViewController,StoryboardInitializable {
    
    fileprivate var searchBar: UISearchBar!
    fileprivate var tableView: UITableView!
    
    var safeArea: UILayoutGuide!
    
    let activityIndicator = ActivityIndicator()
    
    var viewModel: SearchRepositoryViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
         let configureCell = { (tableView: UITableView, row: Int, repository: Repository) -> UITableViewCell in
            var cell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)!
            cell = UITableViewCell(style: .subtitle,
                                   reuseIdentifier: reuseIdentifier)
            cell.textLabel?.text = repository.name
            cell.detailTextLabel?.text = repository.url.absoluteString
            return cell
         }

         let triggerLoadNextPage: (Driver<SearchState>) -> Signal<SearchEvent> = { state in
             return state.flatMapLatest { state -> Signal<SearchEvent> in
                 if state.shouldLoadNextPage {
                     return Signal.empty()
                 }
                 
                return self.tableView.rx.nearBottom
                     .skip(1)
                     .map { _ in SearchEvent.scrollingNearBottom }
             }
         }

         let bindUI: (Driver<SearchState>) -> Signal<SearchEvent> = bind(self) { me, state in
             let subscriptions = [
                 state.map { $0.search }.drive(me.searchBar.rx.text),
                 state.map { $0.results }.drive(self.tableView.rx.items)(configureCell),
                 ]

             let events: [Signal<SearchEvent>] = [
                me.searchBar.rx.text.orEmpty
                .skip(2)
                    .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
                    .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
                    .asSignal(onErrorJustReturn: "SearchBar Error.....")
                    .map(SearchEvent.searchChanged),
                triggerLoadNextPage(state)
             ]

             return Bindings(subscriptions: subscriptions, events: events)
         }
        
       
         Driver.system(
                 initialState: SearchState.empty,
                 reduce: SearchState.reduce,
                 feedback:
                     // UI, user feedback
                     bindUI,
                     // NoUI, automatic feedback
                     react(request: { $0.loadNextPage }, effects: { query in
                        return self.viewModel.searchRepository(by: query.searchText, nextPage: query.nextPage)
                            .observeOn(MainScheduler.asyncInstance)
                             .asSignal(onErrorJustReturn: .failure(.offline))
                             .map(SearchEvent.response)
                     })
             )
            .drive()
             .disposed(by: disposeBag)
    }
    
    private func setupUI(){
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        
        searchBar = UISearchBar()
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        tableView = UITableView()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
}


extension UIScrollView {
    func  isNearBottomEdge(edgeOffset: CGFloat = startLoadingOffset) -> Bool {
        return self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
    }
}

// MARK: Table view delegate

extension SearchRepositoryViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}

class ViewController: UIViewController {
    var disposeBag = DisposeBag()
}

