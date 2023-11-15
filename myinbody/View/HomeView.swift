//
//  HomeView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/12/23.
//

import SwiftUI

struct HomeView: View {
    @State var isSignin = AuthManager.shared.isSignined
    var body: some View {
        VStack {
            if isSignin {
                ProfileListView()                
            } else {
                AnimatedImageView(images: [
                    "figure.stand",
                    "figure.walk",
                    "figure.wave",
                    "figure.fall",
                    "figure.run",
                    "figure.roll",
                    "figure.archery",
                    "figure.badminton",
                    "figure.barre",
                    "figure.baseball",
                    "figure.basketball",
                    "figure.bowling",
                    "figure.boxing",
                    "figure.climbing",
                    "figure.cooldown",
                    "figure.cricket",
                    "figure.curling",
                    "figure.dance",
                    "figure.elliptical",
                    "figure.fencing",
                    "figure.fishing",
                    "figure.flexibility",
                    "figure.golf",
                    "figure.gymnastics",
                    "figure.handball",
                    "figure.hiking",
                    "figure.hockey",
                    "figure.hunting",
                    "figure.jumprope",
                    "figure.kickboxing",
                    "figure.lacrosse",
                    "figure.pickleball",
                    "figure.pilates",
                    "figure.play",
                    "figure.racquetball",
                    "figure.rolling",
                    "figure.rower",
                    "figure.rugby",
                    "figure.sailing",
                    "figure.skating",
                    "figure.snowboarding",
                    "figure.soccer",
                    "figure.socialdance",
                    "figure.softball",
                    "figure.squash",
                    "figure.stairs",
                    "figure.surfing",
                    "figure.taichi",
                    "figure.tennis",
                    "figure.volleyball",
                    "figure.waterpolo",
                    "figure.wrestling",
                    "figure.yoga",
                    "figure.child",
                    "figure.dress.line.vertical.figure",
                    "figure.arms.open",
                    "figure.walk.circle",
                    "figure.walk.diamond",
                    "figure.walk.arrival",
                    "figure.walk.departure",
                    "figure.walk.motion",
                    "figure.wave.circle",
                    "figure.fall.circle",
                    "figure.run.circle",
                    "figure.roll.runningpace",
                    "figure.american.football",
                    "figure.australian.football",
                    "figure.core.training",
                    "figure.skiing.crosscountry",
                    "figure.cross.training",
                    "figure.disc.sports",
                    "figure.skiing.downhill",
                    "figure.equestrian.sports",
                    "figure.strengthtraining.functional",
                    "figure.hand.cycling",
                    "figure.highintensity.intervaltraining",
                    "figure.indoor.cycle",
                    "figure.martial.arts",
                    "figure.mixed.cardio",
                    "figure.outdoor.cycle",
                    "figure.pool.swim",
                    "figure.stair.stepper",
                    "figure.step.training",
                    "figure.table.tennis",
                    "figure.strengthtraining.traditional",
                    "figure.water.fitness"].shuffled().map({ value in
                    Image(systemName: value)
                    }), interval: 2, forgroundStyle: (.yellow,.blue,.secondary), size: .init(
                        width:UIScreen.main.bounds.width * 0.5,
                        height:UIScreen.main.bounds.height * 0.5))
                .padding(50)
                
                Text("app desc home")
                    .font(.caption2)
                    .bold()
                    .padding(20)
                
                NavigationLink {
                    SignInView()
                } label: {
                    Text("signin")
                        .font(.title)
                        .bold()
                }
                
            }
        }
        .navigationTitle(Text("home"))
        .onAppear {
            ProfileModel.sync { error in
                isSignin = AuthManager.shared.isSignined
            }
        }
    }
    
}

#Preview {
    HomeView()
}
