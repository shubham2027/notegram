import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  final String email;
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.email, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: themeProvider.gradientColors,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 480),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 20 : 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Profile Details Section
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(isMobile ? 16 : 20),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Profile Details',
                                    style: TextStyle(
                                      fontSize: isMobile ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  SizedBox(height: isMobile ? 12 : 16),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.email,
                                        color: const Color(0xFF667eea),
                                        size: isMobile ? 20 : 24,
                                      ),
                                      SizedBox(width: isMobile ? 8 : 12),
                                      Expanded(
                                        child: Text(
                                          email,
                                          style: TextStyle(
                                            fontSize: isMobile ? 14 : 16,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isMobile ? 16 : 20),
                            
                            // Theme Settings Section
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(isMobile ? 16 : 20),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Theme Settings',
                                    style: TextStyle(
                                      fontSize: isMobile ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Switch(
                                    value: themeProvider.isDarkMode,
                                    onChanged: (value) {
                                      themeProvider.toggleTheme();
                                    },
                                    activeColor: const Color(0xFF667eea),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isMobile ? 16 : 20),
                            
                            // About Section
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                                    ),
                                    title: Text(
                                      'About Notegram',
                                      style: TextStyle(
                                        fontSize: isMobile ? 18 : 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Version: 1.0.0',
                                          style: TextStyle(
                                            fontSize: isMobile ? 14 : 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Status: Under Development',
                                          style: TextStyle(
                                            fontSize: isMobile ? 14 : 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Notegram is a note-taking app that allows you to create, organize, and share your notes. Features include real-time sync, public/private notes, and a modern interface.',
                                          style: TextStyle(fontSize: isMobile ? 13 : 15),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: Text(
                                          'Close',
                                          style: TextStyle(fontSize: isMobile ? 14 : 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(isMobile ? 16 : 20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'About Us',
                                      style: TextStyle(
                                        fontSize: isMobile ? 16 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.grey[600],
                                      size: isMobile ? 18 : 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: isMobile ? 24 : 32),
                            
                            // Logout Button
                            SizedBox(
                              width: double.infinity,
                              height: isMobile ? 48 : 56,
                              child: ElevatedButton(
                                onPressed: onLogout,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                                  ),
                                ),
                                child: Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: isMobile ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
