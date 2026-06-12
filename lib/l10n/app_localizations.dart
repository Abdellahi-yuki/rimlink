import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// The app title
  ///
  /// In en, this message translates to:
  /// **'RimLink'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @myNetwork.
  ///
  /// In en, this message translates to:
  /// **'My Network'**
  String get myNetwork;

  /// No description provided for @jobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobs;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchJobs.
  ///
  /// In en, this message translates to:
  /// **'Search jobs'**
  String get searchJobs;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search posts or people...'**
  String get searchHint;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @joinRimLink.
  ///
  /// In en, this message translates to:
  /// **'Join RimLink'**
  String get joinRimLink;

  /// No description provided for @stayUpdated.
  ///
  /// In en, this message translates to:
  /// **'Stay updated on your professional world.'**
  String get stayUpdated;

  /// No description provided for @makeMost.
  ///
  /// In en, this message translates to:
  /// **'Make the most of your professional life.'**
  String get makeMost;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @agreeAndJoin.
  ///
  /// In en, this message translates to:
  /// **'Agree & Join'**
  String get agreeAndJoin;

  /// No description provided for @newToRimLink.
  ///
  /// In en, this message translates to:
  /// **'New to RimLink? Join now'**
  String get newToRimLink;

  /// No description provided for @alreadyOnRimLink.
  ///
  /// In en, this message translates to:
  /// **'Already on RimLink? Sign in'**
  String get alreadyOnRimLink;

  /// No description provided for @checkEmail.
  ///
  /// In en, this message translates to:
  /// **'Please check your inbox to confirm your email address!'**
  String get checkEmail;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'These credentials do not exist in the records.'**
  String get invalidCredentials;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unexpectedError;

  /// No description provided for @createAPost.
  ///
  /// In en, this message translates to:
  /// **'Create a post'**
  String get createAPost;

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No posts yet. Be the first to share something!'**
  String get noPostsYet;

  /// No description provided for @editPost.
  ///
  /// In en, this message translates to:
  /// **'Edit post'**
  String get editPost;

  /// No description provided for @deletePost.
  ///
  /// In en, this message translates to:
  /// **'Delete post'**
  String get deletePost;

  /// No description provided for @deletePostConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post?'**
  String get deletePostConfirm;

  /// No description provided for @editPostTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get editPostTitle;

  /// No description provided for @writeSomething.
  ///
  /// In en, this message translates to:
  /// **'Write something...'**
  String get writeSomething;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @sharePost.
  ///
  /// In en, this message translates to:
  /// **'Share post'**
  String get sharePost;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @whatToTalkAbout.
  ///
  /// In en, this message translates to:
  /// **'What do you want to talk about?'**
  String get whatToTalkAbout;

  /// No description provided for @failedToPost.
  ///
  /// In en, this message translates to:
  /// **'Failed to post'**
  String get failedToPost;

  /// No description provided for @postReposted.
  ///
  /// In en, this message translates to:
  /// **'Post reposted'**
  String get postReposted;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorLoadingPosts.
  ///
  /// In en, this message translates to:
  /// **'Error loading posts'**
  String get errorLoadingPosts;

  /// No description provided for @postDetail.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postDetail;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @repost.
  ///
  /// In en, this message translates to:
  /// **'Repost'**
  String get repost;

  /// No description provided for @leaveComment.
  ///
  /// In en, this message translates to:
  /// **'Leave a comment'**
  String get leaveComment;

  /// No description provided for @editComment.
  ///
  /// In en, this message translates to:
  /// **'Edit Comment'**
  String get editComment;

  /// No description provided for @editYourComment.
  ///
  /// In en, this message translates to:
  /// **'Edit your comment'**
  String get editYourComment;

  /// No description provided for @commentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Comment updated successfully'**
  String get commentUpdated;

  /// No description provided for @deleteComment.
  ///
  /// In en, this message translates to:
  /// **'Delete comment'**
  String get deleteComment;

  /// No description provided for @deleteCommentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this comment?'**
  String get deleteCommentConfirm;

  /// No description provided for @errorPostingComment.
  ///
  /// In en, this message translates to:
  /// **'Error posting comment'**
  String get errorPostingComment;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get account;

  /// No description provided for @accountPreferences.
  ///
  /// In en, this message translates to:
  /// **'Account preferences'**
  String get accountPreferences;

  /// No description provided for @signInAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Sign in & security'**
  String get signInAndSecurity;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'ACTIONS'**
  String get actions;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @profileInformation.
  ///
  /// In en, this message translates to:
  /// **'Profile information'**
  String get profileInformation;

  /// No description provided for @nameLocationIndustry.
  ///
  /// In en, this message translates to:
  /// **'Name, location, and industry'**
  String get nameLocationIndustry;

  /// No description provided for @firstNameLastName.
  ///
  /// In en, this message translates to:
  /// **'First and last name'**
  String get firstNameLastName;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @industryTitle.
  ///
  /// In en, this message translates to:
  /// **'Industry (Title)'**
  String get industryTitle;

  /// No description provided for @preferencesSaved.
  ///
  /// In en, this message translates to:
  /// **'Preferences saved successfully'**
  String get preferencesSaved;

  /// No description provided for @accountAccess.
  ///
  /// In en, this message translates to:
  /// **'Account access'**
  String get accountAccess;

  /// No description provided for @emailAddresses.
  ///
  /// In en, this message translates to:
  /// **'Email addresses'**
  String get emailAddresses;

  /// No description provided for @oneEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'1 email address'**
  String get oneEmailAddress;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @primaryEmailAccount.
  ///
  /// In en, this message translates to:
  /// **'Primary email account'**
  String get primaryEmailAccount;

  /// No description provided for @primary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primary;

  /// No description provided for @addEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Add email address'**
  String get addEmailAddress;

  /// No description provided for @addEmailComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Add email flow coming soon!'**
  String get addEmailComingSoon;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Type your current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'Type your new password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Retype your new password'**
  String get confirmNewPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match!'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordMinLength;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password successfully changed!'**
  String get passwordChanged;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Create a new, strong password that you don\'t use for other websites.'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @verificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification sent to primary email address.'**
  String get verificationSent;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @manageNetwork.
  ///
  /// In en, this message translates to:
  /// **'Manage my network'**
  String get manageNetwork;

  /// No description provided for @sentInvitations.
  ///
  /// In en, this message translates to:
  /// **'Sent invitations'**
  String get sentInvitations;

  /// No description provided for @connections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get connections;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @peopleYouMayKnow.
  ///
  /// In en, this message translates to:
  /// **'People you may know'**
  String get peopleYouMayKnow;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @invitationCancelled.
  ///
  /// In en, this message translates to:
  /// **'Invitation cancelled'**
  String get invitationCancelled;

  /// No description provided for @invitationSent.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent'**
  String get invitationSent;

  /// No description provided for @noPendingInvitations.
  ///
  /// In en, this message translates to:
  /// **'No pending invitations'**
  String get noPendingInvitations;

  /// No description provided for @myJobs.
  ///
  /// In en, this message translates to:
  /// **'My jobs'**
  String get myJobs;

  /// No description provided for @mySavedJobs.
  ///
  /// In en, this message translates to:
  /// **'My saved jobs'**
  String get mySavedJobs;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get recommendedForYou;

  /// No description provided for @jobsYouSaved.
  ///
  /// In en, this message translates to:
  /// **'Jobs you have saved for later'**
  String get jobsYouSaved;

  /// No description provided for @basedOnProfile.
  ///
  /// In en, this message translates to:
  /// **'Based on your profile and search history'**
  String get basedOnProfile;

  /// No description provided for @noSavedJobs.
  ///
  /// In en, this message translates to:
  /// **'No saved jobs found.'**
  String get noSavedJobs;

  /// No description provided for @noJobsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No jobs available at the moment.'**
  String get noJobsAvailable;

  /// No description provided for @postAJob.
  ///
  /// In en, this message translates to:
  /// **'Post a Job'**
  String get postAJob;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get jobTitle;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @locationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Location (e.g., Remote, New York, NY)'**
  String get locationPlaceholder;

  /// No description provided for @jobDescription.
  ///
  /// In en, this message translates to:
  /// **'Job Description'**
  String get jobDescription;

  /// No description provided for @applyLink.
  ///
  /// In en, this message translates to:
  /// **'Apply Link (URL)'**
  String get applyLink;

  /// No description provided for @promotedJob.
  ///
  /// In en, this message translates to:
  /// **'Promoted Job'**
  String get promotedJob;

  /// No description provided for @postJob.
  ///
  /// In en, this message translates to:
  /// **'Post Job'**
  String get postJob;

  /// No description provided for @jobPosted.
  ///
  /// In en, this message translates to:
  /// **'Job posted successfully!'**
  String get jobPosted;

  /// No description provided for @errorPostingJob.
  ///
  /// In en, this message translates to:
  /// **'Error posting job'**
  String get errorPostingJob;

  /// No description provided for @easyApply.
  ///
  /// In en, this message translates to:
  /// **'Easy Apply'**
  String get easyApply;

  /// No description provided for @jobDescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Description'**
  String get jobDescriptionTitle;

  /// No description provided for @editJob.
  ///
  /// In en, this message translates to:
  /// **'Edit Job'**
  String get editJob;

  /// No description provided for @saveJob.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveJob;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @applyNow.
  ///
  /// In en, this message translates to:
  /// **'Apply now'**
  String get applyNow;

  /// No description provided for @aboutTheJob.
  ///
  /// In en, this message translates to:
  /// **'About the job'**
  String get aboutTheJob;

  /// No description provided for @noJobDescription.
  ///
  /// In en, this message translates to:
  /// **'Job description not provided.'**
  String get noJobDescription;

  /// No description provided for @noApplyLink.
  ///
  /// In en, this message translates to:
  /// **'No application link provided.'**
  String get noApplyLink;

  /// No description provided for @jobSaved.
  ///
  /// In en, this message translates to:
  /// **'Job saved!'**
  String get jobSaved;

  /// No description provided for @jobRemoved.
  ///
  /// In en, this message translates to:
  /// **'Job removed.'**
  String get jobRemoved;

  /// No description provided for @jobUpdated.
  ///
  /// In en, this message translates to:
  /// **'Job updated successfully!'**
  String get jobUpdated;

  /// No description provided for @jobDeleted.
  ///
  /// In en, this message translates to:
  /// **'Job deleted successfully'**
  String get jobDeleted;

  /// No description provided for @errorUpdatingJob.
  ///
  /// In en, this message translates to:
  /// **'Error updating job'**
  String get errorUpdatingJob;

  /// No description provided for @errorLoadingJobs.
  ///
  /// In en, this message translates to:
  /// **'Error loading jobs'**
  String get errorLoadingJobs;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact info'**
  String get contactInfo;

  /// No description provided for @editContactInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Contact Info'**
  String get editContactInfo;

  /// No description provided for @makeEmailPublic.
  ///
  /// In en, this message translates to:
  /// **'Make email public'**
  String get makeEmailPublic;

  /// No description provided for @makePhonePublic.
  ///
  /// In en, this message translates to:
  /// **'Make phone public'**
  String get makePhonePublic;

  /// No description provided for @contactInfoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Contact info updated successfully'**
  String get contactInfoUpdated;

  /// No description provided for @noContactInfo.
  ///
  /// In en, this message translates to:
  /// **'No contact information available'**
  String get noContactInfo;

  /// No description provided for @addToProfile.
  ///
  /// In en, this message translates to:
  /// **'Add to profile'**
  String get addToProfile;

  /// No description provided for @addExperience.
  ///
  /// In en, this message translates to:
  /// **'Add experience'**
  String get addExperience;

  /// No description provided for @addEducation.
  ///
  /// In en, this message translates to:
  /// **'Add education'**
  String get addEducation;

  /// No description provided for @addSkills.
  ///
  /// In en, this message translates to:
  /// **'Add skills'**
  String get addSkills;

  /// No description provided for @addExperienceTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Experience'**
  String get addExperienceTitle;

  /// No description provided for @editExperienceTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Experience'**
  String get editExperienceTitle;

  /// No description provided for @addEducationTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Education'**
  String get addEducationTitle;

  /// No description provided for @editEducationTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Education'**
  String get editEducationTitle;

  /// No description provided for @school.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get school;

  /// No description provided for @degree.
  ///
  /// In en, this message translates to:
  /// **'Degree (e.g., Bachelor of Science)'**
  String get degree;

  /// No description provided for @fieldOfStudy.
  ///
  /// In en, this message translates to:
  /// **'Field of Study (e.g., Computer Science)'**
  String get fieldOfStudy;

  /// No description provided for @startDateExample.
  ///
  /// In en, this message translates to:
  /// **'Start Date (e.g., Jan 2020)'**
  String get startDateExample;

  /// No description provided for @endDateExample.
  ///
  /// In en, this message translates to:
  /// **'End Date (optional, e.g., Jan 2024 or leave blank if ongoing)'**
  String get endDateExample;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @jobTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get jobTitleLabel;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date (e.g., Jan 2020)'**
  String get startDate;

  /// No description provided for @endDateOptional.
  ///
  /// In en, this message translates to:
  /// **'End Date (optional)'**
  String get endDateOptional;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @openTo.
  ///
  /// In en, this message translates to:
  /// **'Open to'**
  String get openTo;

  /// No description provided for @addSection.
  ///
  /// In en, this message translates to:
  /// **'Add section'**
  String get addSection;

  /// No description provided for @findingNewJob.
  ///
  /// In en, this message translates to:
  /// **'Finding a new job'**
  String get findingNewJob;

  /// No description provided for @openToWorkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show recruiters and others that you are open to work'**
  String get openToWorkSubtitle;

  /// No description provided for @hiring.
  ///
  /// In en, this message translates to:
  /// **'Hiring'**
  String get hiring;

  /// No description provided for @hiringSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share that you are hiring and attract qualified candidates'**
  String get hiringSubtitle;

  /// No description provided for @providingServices.
  ///
  /// In en, this message translates to:
  /// **'Providing services'**
  String get providingServices;

  /// No description provided for @providingServicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Showcase services you offer so new clients can discover you'**
  String get providingServicesSubtitle;

  /// No description provided for @removeOpenToWork.
  ///
  /// In en, this message translates to:
  /// **'Remove \"Open to work\"'**
  String get removeOpenToWork;

  /// No description provided for @removeHiring.
  ///
  /// In en, this message translates to:
  /// **'Remove \"Hiring\"'**
  String get removeHiring;

  /// No description provided for @removeProvidingServices.
  ///
  /// In en, this message translates to:
  /// **'Remove \"Providing services\"'**
  String get removeProvidingServices;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @addYourSummary.
  ///
  /// In en, this message translates to:
  /// **'Add your summary here.'**
  String get addYourSummary;

  /// No description provided for @nothingInAbout.
  ///
  /// In en, this message translates to:
  /// **'Nothing in the About section'**
  String get nothingInAbout;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @noExperienceAdded.
  ///
  /// In en, this message translates to:
  /// **'No experience added yet.'**
  String get noExperienceAdded;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @noEducationAdded.
  ///
  /// In en, this message translates to:
  /// **'No education added yet.'**
  String get noEducationAdded;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @noSkillsAdded.
  ///
  /// In en, this message translates to:
  /// **'No skills added yet.'**
  String get noSkillsAdded;

  /// No description provided for @profileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Profile not found.'**
  String get profileNotFound;

  /// No description provided for @openToWorkBadge.
  ///
  /// In en, this message translates to:
  /// **'#OPENTOWORK'**
  String get openToWorkBadge;

  /// No description provided for @hiringBadge.
  ///
  /// In en, this message translates to:
  /// **'#HIRING'**
  String get hiringBadge;

  /// No description provided for @providingServicesBadge.
  ///
  /// In en, this message translates to:
  /// **'PROVIDING SERVICES'**
  String get providingServicesBadge;

  /// Number of connections
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} connection} other{{count} connections}}'**
  String connectionCount(int count);

  /// Number of comments
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} comment} other{{count} comments}}'**
  String commentsCount(int count);

  /// Repost header
  ///
  /// In en, this message translates to:
  /// **'{name} reposted'**
  String reposted(String name);

  /// Image counter in viewer
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String imageCounter(int current, int total);

  /// No description provided for @noPeopleFound.
  ///
  /// In en, this message translates to:
  /// **'No people found.'**
  String get noPeopleFound;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @noEmailAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get noEmailAvailable;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @unknownSchool.
  ///
  /// In en, this message translates to:
  /// **'Unknown School'**
  String get unknownSchool;

  /// No description provided for @deleteEducation.
  ///
  /// In en, this message translates to:
  /// **'Delete education'**
  String get deleteEducation;

  /// No description provided for @deleteEducationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this education?'**
  String get deleteEducationConfirm;

  /// No description provided for @deleteExperience.
  ///
  /// In en, this message translates to:
  /// **'Delete experience'**
  String get deleteExperience;

  /// No description provided for @deleteExperienceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this experience?'**
  String get deleteExperienceConfirm;

  /// No description provided for @errorUpdatingContact.
  ///
  /// In en, this message translates to:
  /// **'Error updating contact info'**
  String get errorUpdatingContact;

  /// No description provided for @endorsedByConnections.
  ///
  /// In en, this message translates to:
  /// **'Endorsed by multiple connections'**
  String get endorsedByConnections;

  /// No description provided for @uploadImageError.
  ///
  /// In en, this message translates to:
  /// **'Error uploading image'**
  String get uploadImageError;

  /// Number of posts
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} post} other{{count} posts}}'**
  String postsCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
