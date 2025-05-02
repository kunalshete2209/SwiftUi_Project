//
//  Home.swift
//  HabitTracker
//
//  Created by Kunal Shete on 13/03/25.
//

import SwiftUI

struct Home: View {
    
    @FetchRequest(entity: Habit.entity(), sortDescriptors: [NSSortDescriptor(keyPath:\Habit.dateAdded, ascending: false)], predicate: nil, animation: .easeInOut) var
    habits: FetchedResults<Habit>
    
    @StateObject var habitModel: HabitViewModel = .init()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false //  Store theme preference
    
    var body: some View {
        VStack(spacing: 0){
            Text("Habits")
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .overlay (alignment: .trailing) {
                    Button {
                        isDarkMode.toggle() // Toggle theme
                    } label: {
                        Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                            .font(.title3)
                            .foregroundColor(isDarkMode ? .white : .black) // Adjust color based on theme
                    }
                    .accessibilityIdentifier("themeToggleButton")
                }
                .padding(.bottom , 10)
            
            ScrollView(habits.isEmpty ? .init() : .vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    ForEach(habits) { habit in
                        HabitCardView(habit: habit)
                    }
                    
                    // MARK: Add Habit Button
                    Button {
                        habitModel.addNewHabit.toggle()
                    } label: {
                        Label {
                            Text("New Habit")
                        } icon: {
                            Image(systemName: "plus.circle")
                        }
                        .font(.callout.bold())
                        .foregroundColor(isDarkMode ? .white : .black) // Adjust text and icon color
                        .padding(.top, 15)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                    .accessibilityIdentifier("addHabitButton")
                    .padding(.vertical)
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
        .sheet(isPresented: $habitModel.addNewHabit) {
            habitModel.resetData()
        } content: {
            AddNewHabit().environmentObject(habitModel)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light) // Apply theme globally
    }
    
    @ViewBuilder
    func HabitCardView(habit: Habit) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text(habit.title ?? "")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Image(systemName: "bell.badge.fill")
                    .font(.callout)
                    .foregroundColor(Color(habit.color ?? "Card-1"))
                    .scaleEffect(0.9)
                    .opacity(habit.isRemainderOn ? 1 : 0)
                
                Spacer()
                
                let count = (habit.weekDays?.count ?? 0)
                Text(count == 7 ? "Everyday" : "\(count) times a week")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 10)
            
            // MARK: Displaying Current Week and Marking Active Dates of Habit
            let calendar = Calendar.current
            let currentWeek = calendar.dateInterval(of: .weekOfMonth, for: Date())
            let symbols = calendar.weekdaySymbols
            let startDate = currentWeek?.start ?? Date()
            let activeWeekDays = habit.weekDays ?? []
            
            //This is used to track the done button status
            let todayWeekday = calendar.weekdaySymbols[calendar.component(.weekday, from: Date()) - 1]
            let isScheduledForToday = habit.weekDays?.contains(todayWeekday) ?? false
            
            
            let activePlot = symbols.indices.compactMap { index -> (String, Date) in
                let currentDate = calendar.date(byAdding: .day, value: index, to: startDate)
                return (symbols[index], currentDate!)
            }
            
            HStack(spacing: 0) {
                ForEach(activePlot.indices, id: \.self) { index in
                    let item = activePlot[index]
                    VStack(spacing: 6) {
                        Text(item.0.prefix(3))
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        let status = activeWeekDays.contains(item.0)
                        Text(getDate(date: item.1))
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                            .padding(8)
                            .background {
                                Circle()
                                    .fill(Color(habit.color ?? "Card-1"))
                                    .opacity(status ? 1 : 0)
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 15)
            
            // MARK: Streak Display
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("\(habit.streakCount) day streak")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.top, 5)
            
            // MARK: Done Button (Only for Selected Days)
            // Check if the habit was already completed today
            let isCompletedToday: Bool = {
                guard let lastCompletedDate = habit.lastCompletedDate else { return false }
                return Calendar.current.isDate(lastCompletedDate, inSameDayAs: Date())
            }()
            Button(action: {
                habitModel.markHabitAsDone(habit: habit)
            }) {
                Text("Done")
                    .font(.caption)
                    .padding(8)
                    .background((isScheduledForToday && !isCompletedToday) ? Color.green : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 5)
            .disabled(!isScheduledForToday || isCompletedToday) //  Disable if not today or already done


        }
        .padding(.vertical)
        .padding(.horizontal, 6)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("TFBG").opacity(0.5))
        }
        .onTapGesture {
            habitModel.editHabit = habit
            habitModel.restoreEditData()
            habitModel.addNewHabit.toggle()
        }
        .accessibilityElement()
        .accessibilityIdentifier("habitCard")
    }
    
    func getDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }
}

#Preview {
    Home()
}
